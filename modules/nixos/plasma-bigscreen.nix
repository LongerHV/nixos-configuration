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
          user = config.mySystem.user;
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

    # Include color-schemes in the system-path so all apps (Brave, Spotify, etc.)
    # can find BreezeDark.colors via XDG data dirs. Not in NixOS's default pathsToLink.
    environment.pathsToLink = [ "/share/color-schemes" ];

    environment.systemPackages = with pkgs.kdePackages; [
      plasma-workspace
      plasma-nano
      plasma-nm
      plasma-pa
      milou
      kscreen
      kdeconnect-kde
      kwin
      breeze
      qqc2-breeze-style
      kactivitymanagerd
      kglobalacceld
      kded
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = "*";
    };

    security.polkit.enable = true;

    programs.kdeconnect.enable = true;

    # kcminit applies KDE style/font/shortcut modules at startup. kcm_style.so hangs for
    # 90s on this setup, blocking the entire session. Bigscreen uses defaults for all of
    # these, so replacing kcminit with a no-op saves 90s of startup time.
    systemd.user.services.plasma-kcminit = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
    };
    # ksmserver is the KDE session save/restore manager. It hangs for another 90s here.
    # A bigscreen TV interface has no session management needs, so replace with a no-op.
    systemd.user.services.plasma-ksmserver = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
        Type = "simple";
        BusName = "";
      };
    };

    # Ensure kactivitymanagerd starts before plasmashell as part of the plasma session.
    # The service has no [Install] section and nothing Wants it by default, so plasmashell
    # aborts with "kactivitymanagerd is not running" before D-Bus activation can trigger it.
    systemd.user.targets.plasma-core = {
      overrideStrategy = "asDropin";
      wants = [ "plasma-kactivitymanagerd.service" ];
    };
    systemd.user.services.plasma-plasmashell = {
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
    # plasma-bigscreen-wayland sets QT_QPA_PLATFORMTHEME=generic AFTER calling
    # dbus-update-activation-environment, but the startplasma-wayland C wrapper
    # calls it again internally — propagating 'generic' to all user services.
    # The portal uses QApplication::palette() (not KColorScheme) to report
    # dark-mode preference, so it needs the KDE platform theme to read kdeglobals.
    # The kwin crash (null QKdeTheme during cold init) is specific to kwin.
    systemd.user.services.plasma-xdg-desktop-portal-kde = {
      overrideStrategy = "asDropin";
      serviceConfig.Environment = [ "QT_QPA_PLATFORMTHEME=kde" ];
    };

    # kwin_wayland_wrapper always uses --xwayland; install Xwayland so it starts
    # properly. Without it kwin enters a degraded state that breaks Wayland input
    # dispatch (cursor moves but pointer/keyboard events are not forwarded to surfaces).
    programs.xwayland.enable = true;
  };
}
