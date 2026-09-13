{ config, lib, pkgs, ... }:

let
  # WayDroidATV ships a stock SurfaceFlinger: nothing under /system calls
  # vendor.waydroid.display@1.x::setLayerName, so waydroid's hwcomposer never
  # receives the "TID:<app>#<task>/<component>" layer names that its per-app
  # window modes match on. single_window_mode_base::should_show() is therefore
  # always false, and `waydroid app launch` ends up tearing down the window a
  # few seconds after start-up instead of showing the app. Full-UI mode does
  # not use those names, so launch the app and then present the whole Android
  # display, which on a TV image is the right presentation anyway.
  waydroid-tv-launch = pkgs.writeShellScriptBin "waydroid-tv-launch" ''
    pkg="''${1:-}"
    if [ -z "$pkg" ]; then
      echo "usage: waydroid-tv-launch <package>" >&2
      exit 1
    fi

    waydroid=${config.virtualisation.waydroid.package}/bin/waydroid

    # Also starts the session when none is running, blocking for its lifetime.
    "$waydroid" app launch "$pkg" &
    launcher=$!

    i=0
    while [ "$i" -lt 120 ]; do
      if [ "$("$waydroid" prop get waydroid.active_apps 2>/dev/null)" = "$pkg" ]; then
        break
      fi
      i=$((i + 1))
      sleep 1
    done
    sleep 2
    "$waydroid" show-full-ui

    wait "$launcher"
  '';

  waydroid-mpris-spotify = pkgs.callPackage ./waydroid-mpris-spotify.nix {
    waydroid = config.virtualisation.waydroid.package;
  };
in
{
  environment.systemPackages = with pkgs; [
    android-tools
    waydroid-tv-launch
    waydroid-mpris-spotify
  ];

  home-manager.users.${config.mySystem.user}.systemd.user.services.waydroid-mpris-spotify = {
    Unit = {
      Description = "MPRIS bridge for Spotify in Waydroid";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      # The Waydroid session may come up long after login; keep retrying.
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "simple";
      # Start the adb server up front: if the script's `adb connect` has to spawn
      # it, the daemon inherits the captured stdout pipe and the call times out.
      ExecStartPre = "${lib.getExe' pkgs.android-tools "adb"} start-server";
      ExecStart = "${lib.getExe waydroid-mpris-spotify} --backend adb";
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  virtualisation = {
    waydroid = {
      enable = true;
      # Android TV apps only declare LEANBACK_LAUNCHER; upstream skips those when
      # syncing .desktop files, so they never reach the Bigscreen menu.
      package = pkgs.waydroid-nftables.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tools/services/user_manager.py \
            --replace-fail \
              'if cat.strip() == "android.intent.category.LAUNCHER":' \
              'if cat.strip() in ("android.intent.category.LAUNCHER", "android.intent.category.LEANBACK_LAUNCHER"):'
          # Route the generated entries through waydroid-tv-launch (see above).
          substituteInPlace tools/services/user_manager.py \
            --replace-fail \
              'f"waydroid app launch {packageName}"' \
              'f"waydroid-tv-launch {packageName}"'
        '';
      });
    };
  };
}
