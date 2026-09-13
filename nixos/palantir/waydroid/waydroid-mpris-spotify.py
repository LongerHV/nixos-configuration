#!/usr/bin/env python3
"""
waydroid-mpris-spotify — expose the Spotify Android TV app running inside
Waydroid as an MPRIS player on the host session bus.

It polls `dumpsys media_session` inside the container for playback state and
metadata, and maps MPRIS transport calls onto `cmd media_session dispatch`.
No companion app, no Spotify account credentials, no network listener.

Usage:
    ./waydroid-mpris-spotify                       # autodetect backend
    ./waydroid-mpris-spotify --backend adb
    ./waydroid-mpris-spotify --probe               # one-shot state dump, no D-Bus
    ./waydroid-mpris-spotify --print-unit          # systemd --user unit to stdout

Requires: python-dbus, python-gobject, and either android-tools (adb) or
passwordless `waydroid shell`.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from typing import Optional

BUS_NAME = "org.mpris.MediaPlayer2.waydroid_spotify"
OBJ_PATH = "/org/mpris/MediaPlayer2"
ROOT_IFACE = "org.mpris.MediaPlayer2"
PLAYER_IFACE = "org.mpris.MediaPlayer2.Player"
PROPS_IFACE = "org.freedesktop.DBus.Properties"

DEFAULT_PACKAGE = "com.spotify.tv.android"

log = logging.getLogger("waydroid-mpris")

# ---------------------------------------------------------------------------
# PlaybackState constants (android.media.session.PlaybackState)
# ---------------------------------------------------------------------------

STATE_NONE, STATE_STOPPED, STATE_PAUSED, STATE_PLAYING = 0, 1, 2, 3
STATE_FAST_FORWARDING, STATE_REWINDING, STATE_BUFFERING = 4, 5, 6
STATE_ERROR, STATE_CONNECTING = 7, 8

PLAYING_STATES = {
    STATE_PLAYING,
    STATE_FAST_FORWARDING,
    STATE_REWINDING,
    STATE_BUFFERING,
    STATE_CONNECTING,
    9,
    10,
    11,
}

ACTION_STOP = 1 << 0
ACTION_PAUSE = 1 << 1
ACTION_PLAY = 1 << 2
ACTION_SKIP_TO_PREVIOUS = 1 << 4
ACTION_SKIP_TO_NEXT = 1 << 5
ACTION_SEEK_TO = 1 << 8
ACTION_PLAY_PAUSE = 1 << 9


# ---------------------------------------------------------------------------
# Container access
# ---------------------------------------------------------------------------


class ShellError(RuntimeError):
    pass


class Backend:
    """Runs a shell command inside the Waydroid container."""

    def __init__(self, mode: str, serial: Optional[str] = None, sudo: bool = False):
        self.mode = mode
        self.serial = serial
        self.sudo = sudo

    # -- construction ------------------------------------------------------

    @classmethod
    def autodetect(
        cls, prefer: str = "auto", serial: Optional[str] = None, sudo: bool = False
    ) -> "Backend":
        if prefer == "adb" or (prefer == "auto" and shutil.which("adb")):
            try:
                return cls._make_adb(serial)
            except ShellError as exc:
                if prefer == "adb":
                    raise
                log.warning(
                    "adb backend unavailable (%s); falling back to waydroid shell", exc
                )
        backend = cls("waydroid", sudo=sudo)
        backend.check()
        return backend

    @classmethod
    def _make_adb(cls, serial: Optional[str]) -> "Backend":
        if not shutil.which("adb"):
            raise ShellError("adb not found in PATH")
        serial = serial or cls._resolve_waydroid_serial()
        subprocess.run(
            ["adb", "connect", serial], capture_output=True, text=True, timeout=10
        )
        backend = cls("adb", serial=serial)
        backend.check()
        return backend

    @staticmethod
    def _resolve_waydroid_serial() -> str:
        try:
            out = subprocess.run(
                ["waydroid", "status"], capture_output=True, text=True, timeout=10
            ).stdout
        except (OSError, subprocess.SubprocessError) as exc:
            raise ShellError(f"could not run `waydroid status`: {exc}") from exc
        m = re.search(r"IP address:\s*(\S+)", out)
        if not m:
            raise ShellError(
                "no IP address in `waydroid status` — is the session running?"
            )
        return f"{m.group(1)}:5555"

    # -- execution ---------------------------------------------------------

    def _argv(self, args: list[str]) -> list[str]:
        if self.mode == "adb":
            return ["adb", "-s", self.serial, "shell", *args]
        prefix = ["sudo", "-n"] if self.sudo else []
        return [*prefix, "waydroid", "shell", "--", *args]

    def run(self, args: list[str], timeout: float = 8.0) -> str:
        argv = self._argv(args)
        try:
            proc = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
        except subprocess.TimeoutExpired as exc:
            raise ShellError(f"timeout running {' '.join(args)}") from exc
        except OSError as exc:
            raise ShellError(f"could not execute {argv[0]}: {exc}") from exc
        if proc.returncode != 0:
            err = (proc.stderr or proc.stdout).strip().splitlines()
            raise ShellError(err[0] if err else f"exit status {proc.returncode}")
        return proc.stdout

    def check(self) -> None:
        out = self.run(["echo", "waydroid-mpris-ok"], timeout=15)
        if "waydroid-mpris-ok" not in out:
            raise ShellError(f"unexpected response from container: {out!r}")
        log.info(
            "backend ready: %s%s", self.mode, f" ({self.serial})" if self.serial else ""
        )


# ---------------------------------------------------------------------------
# dumpsys parsing
# ---------------------------------------------------------------------------


@dataclass
class Snapshot:
    found: bool = False
    state: int = STATE_NONE
    position_ms: int = 0
    speed: float = 1.0
    updated_ms: int = 0  # SystemClock.elapsedRealtime at state update
    actions: int = 0
    title: Optional[str] = None
    artist: Optional[str] = None
    album: Optional[str] = None
    package: Optional[str] = None

    @property
    def playback_status(self) -> str:
        if not self.found or self.state in (STATE_NONE, STATE_ERROR):
            return "Stopped"
        if self.state in PLAYING_STATES:
            return "Playing"
        if self.state == STATE_PAUSED:
            return "Paused"
        return "Stopped"

    def identity_key(self) -> tuple:
        return (
            self.found,
            self.title,
            self.artist,
            self.album,
            self.playback_status,
            self.actions,
        )


# Newer Android prefixes the header with the session tag:
#   "    <tag> <package>/<tag>/<id> (userId=0)"
_SESSION_HEADER = re.compile(
    r"^\s{2,}(?:\S+\s+)?([^\s/]+)/(\S*)\s*\(userId=(\d+)\)\s*$"
)
# The state is either a bare number or "PLAYING(3)", depending on the release.
_STATE_RE = re.compile(
    r"state=PlaybackState\s*\{.*?state=(?:\w+\()?(\d+)\)?.*?position=(-?\d+)"
    r".*?speed=(-?[\d.]+).*?updated=(-?\d+).*?actions=(\d+)",
    re.DOTALL,
)
_META_RE = re.compile(r"^\s*metadata:\s*size=\d+,\s*description=(.*)$")
_PACKAGE_RE = re.compile(r"^\s*package=(\S+)\s*$")


def parse_dumpsys(text: str, package: str) -> Snapshot:
    """Pull the media session for `package` out of `dumpsys media_session`."""
    blocks: list[list[str]] = []
    current: Optional[list[str]] = None

    for line in text.splitlines():
        if _SESSION_HEADER.match(line):
            current = [line]
            blocks.append(current)
        elif current is not None:
            current.append(line)

    for block in blocks:
        body = "\n".join(block)
        head = _SESSION_HEADER.match(block[0])
        pkg = head.group(1) if head else None
        for line in block:
            m = _PACKAGE_RE.match(line)
            if m:
                pkg = m.group(1)
                break
        if pkg != package:
            continue

        snap = Snapshot(found=True, package=pkg)

        m = _STATE_RE.search(body)
        if m:
            snap.state = int(m.group(1))
            snap.position_ms = int(m.group(2))
            snap.speed = float(m.group(3))
            snap.updated_ms = int(m.group(4))
            snap.actions = int(m.group(5))

        for line in block:
            m = _META_RE.match(line)
            if m:
                snap.title, snap.artist, snap.album = _split_description(m.group(1))
                break
        return snap

    return Snapshot(found=False)


def _split_description(raw: str) -> tuple[Optional[str], Optional[str], Optional[str]]:
    """MediaDescription.toString() is "title, subtitle, description".

    Titles containing ", " are ambiguous; splitting from the right keeps the
    track name intact, which is the field that matters most.
    """
    parts = raw.strip().rsplit(", ", 2)
    while len(parts) < 3:
        parts.append("null")
    return tuple(None if p.strip() in ("", "null") else p.strip() for p in parts)  # type: ignore


def read_elapsed_realtime(backend: Backend) -> Optional[int]:
    """Container uptime in ms, to anchor PlaybackState.updated timestamps."""
    try:
        out = backend.run(["cat", "/proc/uptime"], timeout=5)
        return int(float(out.split()[0]) * 1000)
    except (ShellError, ValueError, IndexError):
        return None


# ---------------------------------------------------------------------------
# MPRIS object
# ---------------------------------------------------------------------------


def build_mpris(dbus, GLib, backend: Backend, package: str, identity: str):
    import dbus.service

    class Player(dbus.service.Object):
        def __init__(self, bus_name):
            super().__init__(bus_name, OBJ_PATH)
            self.snap = Snapshot()
            self.track_serial = 0
            self._position_us = 0
            self._position_anchor = time.monotonic()
            self._lock = threading.Lock()

        # -- state intake --------------------------------------------------

        def apply(self, snap: Snapshot, position_us: int):
            with self._lock:
                changed_track = (snap.title, snap.artist, snap.album) != (
                    self.snap.title,
                    self.snap.artist,
                    self.snap.album,
                )
                old_key = self.snap.identity_key()
                self.snap = snap
                self._position_us = position_us
                self._position_anchor = time.monotonic()
                if changed_track:
                    self.track_serial += 1
                if snap.identity_key() == old_key:
                    return
                props = {
                    "PlaybackStatus": snap.playback_status,
                    "Metadata": self._metadata(),
                    "CanGoNext": self._can(ACTION_SKIP_TO_NEXT),
                    "CanGoPrevious": self._can(ACTION_SKIP_TO_PREVIOUS),
                    "CanPlay": self._can(ACTION_PLAY | ACTION_PLAY_PAUSE),
                    "CanPause": self._can(ACTION_PAUSE | ACTION_PLAY_PAUSE),
                    "CanControl": True,
                }
            self.PropertiesChanged(PLAYER_IFACE, props, [])

        def _can(self, mask: int) -> bool:
            if not self.snap.found:
                return False
            if self.snap.actions == 0:
                return True  # app published no action mask; assume basics work
            return bool(self.snap.actions & mask)

        def _metadata(self):
            md = dbus.Dictionary(signature="sv")
            md["mpris:trackid"] = dbus.ObjectPath(
                f"{OBJ_PATH}/waydroid/track/{self.track_serial}"
            )
            if not self.snap.found:
                return md
            if self.snap.title:
                md["xesam:title"] = self.snap.title
            if self.snap.artist:
                md["xesam:artist"] = dbus.Array([self.snap.artist], signature="s")
            if self.snap.album:
                md["xesam:album"] = self.snap.album
            return md

        def _live_position_us(self) -> int:
            with self._lock:
                base = self._position_us
                if self.snap.playback_status == "Playing":
                    speed = self.snap.speed if self.snap.speed > 0 else 1.0
                    drift = (time.monotonic() - self._position_anchor) * 1e6
                    base += int(drift * speed)
                return max(base, 0)

        # -- root interface ------------------------------------------------

        def _root_props(self):
            return {
                "CanQuit": False,
                "CanRaise": True,
                "HasTrackList": False,
                "Identity": identity,
                "DesktopEntry": f"waydroid.{package}",
                "SupportedUriSchemes": dbus.Array([], signature="s"),
                "SupportedMimeTypes": dbus.Array([], signature="s"),
            }

        def _player_props(self):
            with self._lock:
                snap = self.snap
                md = self._metadata()
            return {
                "PlaybackStatus": snap.playback_status,
                "LoopStatus": "None",
                "Rate": dbus.Double(1.0),
                "MinimumRate": dbus.Double(1.0),
                "MaximumRate": dbus.Double(1.0),
                "Shuffle": False,
                "Metadata": md,
                "Volume": dbus.Double(1.0),
                "Position": dbus.Int64(self._live_position_us()),
                "CanGoNext": self._can(ACTION_SKIP_TO_NEXT),
                "CanGoPrevious": self._can(ACTION_SKIP_TO_PREVIOUS),
                "CanPlay": self._can(ACTION_PLAY | ACTION_PLAY_PAUSE),
                "CanPause": self._can(ACTION_PAUSE | ACTION_PLAY_PAUSE),
                "CanSeek": False,
                "CanControl": True,
            }

        @dbus.service.method(ROOT_IFACE)
        def Raise(self):
            self._spawn(self._raise_app)

        @dbus.service.method(ROOT_IFACE)
        def Quit(self):
            pass

        def _raise_app(self):
            for category in (
                "android.intent.category.LEANBACK_LAUNCHER",
                "android.intent.category.LAUNCHER",
            ):
                try:
                    backend.run(["monkey", "-p", package, "-c", category, "1"])
                    return
                except ShellError:
                    continue
            log.warning("could not bring %s to the foreground", package)

        # -- player interface ----------------------------------------------

        def _spawn(self, fn, *args):
            threading.Thread(target=fn, args=args, daemon=True).start()

        def _dispatch(self, verb: str, keycode: Optional[int] = None):
            try:
                backend.run(["cmd", "media_session", "dispatch", verb])
                return
            except ShellError as exc:
                log.debug("dispatch %s failed (%s)", verb, exc)
            if keycode is not None:
                try:
                    backend.run(["input", "keyevent", str(keycode)])
                except ShellError as exc:
                    log.warning("keyevent %s failed: %s", keycode, exc)

        @dbus.service.method(PLAYER_IFACE)
        def PlayPause(self):
            self._spawn(self._dispatch, "play-pause", 85)

        @dbus.service.method(PLAYER_IFACE)
        def Play(self):
            self._spawn(self._dispatch, "play", 126)

        @dbus.service.method(PLAYER_IFACE)
        def Pause(self):
            self._spawn(self._dispatch, "pause", 127)

        @dbus.service.method(PLAYER_IFACE)
        def Stop(self):
            self._spawn(self._dispatch, "stop", 86)

        @dbus.service.method(PLAYER_IFACE)
        def Next(self):
            self._spawn(self._dispatch, "next", 87)

        @dbus.service.method(PLAYER_IFACE)
        def Previous(self):
            self._spawn(self._dispatch, "previous", 88)

        @dbus.service.method(PLAYER_IFACE, in_signature="x")
        def Seek(self, offset):
            self._spawn(self._dispatch, "fast-forward" if offset > 0 else "rewind")

        @dbus.service.method(PLAYER_IFACE, in_signature="ox")
        def SetPosition(self, track_id, position):
            pass

        @dbus.service.method(PLAYER_IFACE, in_signature="s")
        def OpenUri(self, uri):
            pass

        @dbus.service.signal(PLAYER_IFACE, signature="x")
        def Seeked(self, position):
            pass

        # -- properties ----------------------------------------------------

        @dbus.service.method(PROPS_IFACE, in_signature="ss", out_signature="v")
        def Get(self, interface, prop):
            return self.GetAll(interface)[prop]

        @dbus.service.method(PROPS_IFACE, in_signature="s", out_signature="a{sv}")
        def GetAll(self, interface):
            if interface == ROOT_IFACE:
                return dbus.Dictionary(self._root_props(), signature="sv")
            if interface == PLAYER_IFACE:
                return dbus.Dictionary(self._player_props(), signature="sv")
            raise dbus.exceptions.DBusException(
                "org.freedesktop.DBus.Error.UnknownInterface", interface
            )

        @dbus.service.method(PROPS_IFACE, in_signature="ssv")
        def Set(self, interface, prop, value):
            pass

        @dbus.service.signal(PROPS_IFACE, signature="sa{sv}as")
        def PropertiesChanged(self, interface, changed, invalidated):
            pass

    return Player


# ---------------------------------------------------------------------------
# Polling
# ---------------------------------------------------------------------------


def poll_once(backend: Backend, package: str) -> tuple[Snapshot, int]:
    text = backend.run(["dumpsys", "media_session"])
    snap = parse_dumpsys(text, package)
    position_us = snap.position_ms * 1000
    if snap.found and snap.playback_status == "Playing" and snap.updated_ms:
        now_ms = read_elapsed_realtime(backend)
        if now_ms is not None:
            delta = now_ms - snap.updated_ms
            # Android's elapsedRealtime and the container's /proc/uptime both
            # come off the host kernel's boot clock, so this is normally a small
            # positive number. Anything else means they aren't comparable here.
            if 0 <= delta <= 300_000:
                position_us += delta * 1000
    return snap, max(position_us, 0)


def poll_loop(backend: Backend, package: str, player, GLib, interval: float):
    failures = 0
    while True:
        try:
            snap, position_us = poll_once(backend, package)
            failures = 0
        except ShellError as exc:
            failures += 1
            log.warning("poll failed (%d): %s", failures, exc)
            if failures >= 3:
                GLib.idle_add(player.apply, Snapshot(found=False), 0)
                if backend.mode == "adb":
                    subprocess.run(
                        ["adb", "connect", backend.serial],
                        capture_output=True,
                        text=True,
                    )
            time.sleep(min(interval * (2 ** min(failures, 5)), 30))
            continue
        GLib.idle_add(player.apply, snap, position_us)
        time.sleep(interval)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


UNIT_TEMPLATE = """[Unit]
Description=MPRIS bridge for Spotify in Waydroid
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart={exe} --backend {backend} --package {package} --poll-interval {interval}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
"""


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    ap.add_argument(
        "--package",
        default=DEFAULT_PACKAGE,
        help=f"Android package to track (default: {DEFAULT_PACKAGE})",
    )
    ap.add_argument("--backend", choices=("auto", "adb", "waydroid"), default="auto")
    ap.add_argument("--device", help="explicit adb serial, e.g. 192.168.240.112:5555")
    ap.add_argument(
        "--sudo",
        action="store_true",
        help="run `waydroid shell` via sudo -n (needs a NOPASSWD rule)",
    )
    ap.add_argument("--poll-interval", type=float, default=1.0)
    ap.add_argument(
        "--identity",
        default="Spotify (Waydroid)",
        help="name shown in the Plasma media controller",
    )
    ap.add_argument(
        "--probe",
        action="store_true",
        help="print one parsed snapshot as JSON and exit",
    )
    ap.add_argument(
        "--raw",
        action="store_true",
        help="with --probe, also print the raw dumpsys block",
    )
    ap.add_argument(
        "--print-unit", action="store_true", help="print a systemd --user unit and exit"
    )
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    if args.print_unit:
        print(
            UNIT_TEMPLATE.format(
                exe=os.path.abspath(sys.argv[0]),
                backend="adb" if args.backend == "auto" else args.backend,
                package=args.package,
                interval=args.poll_interval,
            )
        )
        return 0

    try:
        backend = Backend.autodetect(args.backend, args.device, args.sudo)
    except ShellError as exc:
        log.error("no working backend: %s", exc)
        log.error(
            "start Waydroid, or enable ADB in Android developer options, "
            "or pass --backend waydroid --sudo"
        )
        return 1

    if args.probe:
        text = backend.run(["dumpsys", "media_session"])
        snap, position_us = poll_once(backend, args.package)
        out = {k: v for k, v in vars(snap).items()}
        out["playback_status"] = snap.playback_status
        out["position_seconds"] = round(position_us / 1e6, 1)
        print(json.dumps(out, indent=2))
        if args.raw:
            print("\n--- raw dumpsys media_session ---\n")
            print(text)
        if not snap.found:
            print(
                f"\nNo media session for {args.package}. Start playback first; "
                "if it still shows nothing, run with --raw and check the "
                "package name in the session list.",
                file=sys.stderr,
            )
        return 0

    import dbus
    import dbus.mainloop.glib
    import dbus.service
    from gi.repository import GLib

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    bus_name = dbus.service.BusName(BUS_NAME, bus=bus, do_not_queue=True)

    PlayerClass = build_mpris(dbus, GLib, backend, args.package, args.identity)
    player = PlayerClass(bus_name)
    log.info("registered %s (tracking %s)", BUS_NAME, args.package)

    threading.Thread(
        target=poll_loop,
        args=(backend, args.package, player, GLib, args.poll_interval),
        daemon=True,
    ).start()

    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        log.info("stopping")
    return 0


if __name__ == "__main__":
    sys.exit(main())
