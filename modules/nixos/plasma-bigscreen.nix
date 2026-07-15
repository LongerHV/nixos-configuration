{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.plasma-bigscreen;
in
{
  options.mySystem.plasma-bigscreen = {
    enable = lib.mkEnableOption "plasma-bigscreen";
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        xkb.layout = "pl";
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = {
          enable = true;
          inherit (config.mySystem) user;
        };
        defaultSession = "plasma-bigscreen-wayland";
        sessionPackages = [ pkgs.plasma-bigscreen ];
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    environment = {
      # Include color-schemes in the system-path so all apps (Brave, Spotify, etc.)
      # can find BreezeDark.colors via XDG data dirs. Not in NixOS's default pathsToLink.
      pathsToLink = [ "/share/color-schemes" ];

      # services.desktopManager.plasma6 (below) already installs plasma-workspace,
      # kscreen, kactivitymanagerd, kglobalacceld, kded, kde-cli-tools, kwin, breeze,
      # qqc2-breeze-style, and (since networking.networkmanager.enable and
      # services.pipewire.pulse.enable are both true on this host) plasma-nm and
      # plasma-pa too. Only list what that module doesn't already provide.
      systemPackages = with pkgs.kdePackages; [
        # plasma-bigscreen-wayland (this package's own launcher script) does
        # `. plasma-bigscreen-common-env` with a bare filename, so its own bin/
        # must be on $PATH for that source to resolve when SDDM execs it.
        plasma-bigscreen
        # plasma-bigscreen-specific window management shell; not part of a
        # regular Plasma desktop, so services.desktopManager.plasma6 never installs it.
        plasma-nano
      ];

      # Trim the regular-desktop apps plasma6 installs by default that this
      # HTPC-only bigscreen session never uses. Kept: konsole (on-screen
      # terminal, handy without SSH), qtvirtualkeyboard/plasma-keyboard (no
      # physical keyboard on a TV), plasma-browser-integration (Brave is
      # actually installed on this host, see home.nix).
      plasma6.excludePackages = with pkgs.kdePackages; [
        dolphin
        dolphin-plugins
        baloo-widgets
        gwenview
        okular
        kate
        ktexteditor
        khelpcenter
        ark
        elisa
        spectacle
        kwin-x11
        aurorae
        plasma-workspace-wallpapers
        krdp
        ffmpegthumbs
        union
      ];
    };

    # services.desktopManager.plasma6 (below) already sets xdg.portal.enable and
    # xdg.portal.extraPortals (xdg-desktop-portal-kde, kwallet, xdg-desktop-portal-gtk).
    # configPackages must be re-declared here (not just added to) because plasma6.nix
    # sets it via mkDefault, and this plain assignment would otherwise fully replace
    # rather than merge with it — so plasma-workspace is re-listed explicitly.
    xdg.portal.configPackages = [ pkgs.kdePackages.plasma-workspace pkgs.plasma-bigscreen ];

    security.polkit.enable = true;

    # services.desktopManager.plasma6 defaults this to true (for firmware-update
    # notifications) and, as a side effect, installs the Discover GUI app
    # whenever it or services.flatpak.enable is on — neither is something this
    # HTPC uses, and discover isn't reachable through environment.plasma6.excludePackages
    # (it's added via a separate ++ lib.optionals term, not the excludePackages-filtered
    # optionalPackages list). Disabling it here removes both the background service
    # and the app.
    services.fwupd.enable = false;

    # Standard, upstream-tested Plasma 6 session infrastructure. Brings in
    # plasma-integration (the actual "kde" Qt platform-theme plugin — its
    # absence was the root cause of kwin_wayland crashing on cold init with
    # a SIGSEGV in Qt's built-in QKdeTheme fallback), the cap_sys_nice
    # security wrapper for kwin_wayland, drkonqi crash handling, dconf, and
    # the rest of the session plumbing this module used to hand-assemble
    # incompletely from raw environment.systemPackages.
    services.desktopManager.plasma6.enable = true;

    programs = {
      kdeconnect.enable = true;
      # kwin_wayland_wrapper always uses --xwayland; install Xwayland so it starts
      # properly. Without it kwin enters a degraded state that breaks Wayland input
      # dispatch (cursor moves but pointer/keyboard events are not forwarded to surfaces).
      xwayland.enable = true;
    };

    systemd.user = {
      # Ensure kactivitymanagerd starts before plasmashell as part of the plasma session.
      # The service has no [Install] section and nothing Wants it by default, so plasmashell
      # aborts with "kactivitymanagerd is not running" before D-Bus activation can trigger it.
      targets.plasma-core = {
        overrideStrategy = "asDropin";
        wants = [ "plasma-kactivitymanagerd.service" ];
      };
      services = {
        # kcminit applies KDE style/font/shortcut modules at startup. kcm_style.so hangs for
        # 90s on this setup, blocking the entire session. Bigscreen uses defaults for all of
        # these, so replacing kcminit with a no-op saves 90s of startup time.
        plasma-kcminit = {
          overrideStrategy = "asDropin";
          serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
        };
        # ksmserver is the KDE session save/restore manager. It hangs for another 90s here.
        # A bigscreen TV interface has no session management needs, so replace with a no-op.
        plasma-ksmserver = {
          overrideStrategy = "asDropin";
          serviceConfig = {
            ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
            Type = "simple";
            BusName = "";
          };
        };
        plasma-plasmashell = {
          overrideStrategy = "asDropin";
          after = [ "plasma-kactivitymanagerd.service" ];
          # The startplasma-wayland C wrapper prefixes individual nix store package paths
          # to XDG_DATA_DIRS, but never includes /run/current-system/sw/share or the
          # per-user profile share dir. Plasmashell's app discovery (KSycoca) then misses
          # all system and home-manager installed apps (.desktop files not found).
          # Similarly, NixOS injects a minimal PATH for the service (coreutils etc.) so
          # plasmashell cannot find binaries like kdeconnect-app or plasma-bigscreen-settings.
          # Using serviceConfig.Environment (raw list) avoids conflict with NixOS's own
          # environment.PATH injection; systemd's last-wins rule for Environment= means
          # our entries override the earlier NixOS-generated ones.
          serviceConfig.Environment = [
            # plasma-bigscreen/share is not in plasmashell's build closure so the C
            # wrapper never adds it; without it plasmashell fails with "invalid corona".
            # /etc/profiles/per-user and /run/current-system/sw/share are needed so
            # KSycoca finds .desktop files for user- and system-installed apps.
            # The plasmashell C wrapper prepends its own KDE framework nix store paths on
            # top of this base value, so all framework data dirs are still present.
            "XDG_DATA_DIRS=${pkgs.plasma-bigscreen}/share:/etc/profiles/per-user/${config.mySystem.user}/share:/run/current-system/sw/share"
            # NixOS injects a minimal PATH; our entry here comes after it in the drop-in
            # (serviceConfig entries follow environment.* entries in generated unit files)
            # so systemd's last-wins rule makes our PATH take effect.
            # Order matters: /run/wrappers/bin must precede /run/current-system/sw/bin so
            # that setuid wrappers (sudo, ping, etc.) shadow the nix-store copies.
            # /etc/profiles/per-user includes home-manager user packages (e.g. zsh plugins).
            "PATH=/etc/profiles/per-user/${config.mySystem.user}/bin:${pkgs.plasma-bigscreen}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
          ];
        };
        # Restore QT_QPA_PLATFORMTHEME=kde for the portal process.
        # STALE as of the 2026-07-12 migration to nixpkgs-unstable's plasma-bigscreen
        # package: this compensated for QT_QPA_PLATFORMTHEME=generic being set by the
        # old custom overlay derivation's postInstall script (deleted). Upstream's
        # plasma-bigscreen-wayland.in does not set QT_QPA_PLATFORMTHEME at all, so this
        # override — and the kwin-crash workaround it was protecting against, tuned
        # against Qt 6.10.1 + KWin 6.5.5 — may no longer be necessary. As of the
        # 2026-07-15 switch to services.desktopManager.plasma6, the kwin crash itself
        # is root-caused to a missing plasma-integration package (now fixed), not a
        # theme-value problem, so this may be doubly unnecessary. Verify at runtime
        # before removing.
        # The portal uses QApplication::palette() (not KColorScheme) to report
        # dark-mode preference, so it needs the KDE platform theme to read kdeglobals.
        plasma-xdg-desktop-portal-kde = {
          overrideStrategy = "asDropin";
          serviceConfig.Environment = [ "QT_QPA_PLATFORMTHEME=kde" ];
        };
      };
    };
  };
}
