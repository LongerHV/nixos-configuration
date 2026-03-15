{ pkgs, lib, ... }:

{
  myHome = {
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = false;
    };
  };

  home = {
    stateVersion = "25.11";
    activation = {
      # Apply Breeze Dark color scheme to kdeglobals.
      # plasma-apply-colorscheme copies ALL [Colors:*] sections from BreezeDark.colors
      # into kdeglobals (not just ColorScheme=BreezeDark). xdg-desktop-portal-kde
      # computes dark-mode preference by reading [Colors:Window]BackgroundNormal via
      # KColorScheme — without those entries Brave and other non-KDE apps see light mode.
      # Use activation (not xdg.configFile) so KDE can write runtime theme changes
      # without hitting a read-only nix-store symlink.
      kdeglobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme BreezeDark
        $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
        $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle breeze
      '';

      # Blacklist apps that should not appear in the bigscreen launcher:
      # - cups: CUPS web interface, pulled in via plasmashell's C-wrapper XDG_DATA_DIRS
      #         (no NoDisplay=true, so it always appears as "Manage Printing")
      # - xterm: terminal emulator, irrelevant for HTPC
      # - nixos-manual: NixOS documentation app, irrelevant for HTPC
      # Use kwriteconfig6 (not xdg.configFile) because the ApplicationListModel also
      # writes to this file (allapps debug key); a managed symlink would be replaced
      # by KConfig's atomic write, breaking home-manager's file tracking.
      appBlacklist = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file applications-blacklistrc \
          --group Applications \
          --key blacklist \
          "cups,xterm,nixos-manual,plasma-bigscreen-swap-session,org.kde.plasma.bigscreen.uvcviewer"
      '';

      # Clear stale KSycoca caches on every home-manager switch.
      # NixOS profile switches replace the /etc/profiles/per-user/<user> symlink
      # atomically; inotify watchers on the old target don't fire, so KSycoca
      # never learns about newly installed or removed apps. Deleting all cache
      # files forces the next KSycoca consumer (plasmashell) to rebuild with the
      # current profile.
      clearKSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD rm -f ~/.cache/ksycoca6_*
      '';

      # Enable KDE Connect remote input on Wayland without a permission prompt.
      # KWin's XwaylandEisNoPrompt=true allows EIS-based input injection (used by
      # xdg-desktop-portal-kde's RemoteDesktop backend) without showing a dialog.
      # This is equivalent to System Settings → Legacy X11 App Support →
      # "Control of pointer and keyboard: Allow without asking for permission".
      # We use kwriteconfig6 (merges into existing kwinrc) rather than
      # xdg.configFile (which would overwrite KWin's own runtime writes).
      kwinEisNoPrompt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file kwinrc \
          --group Xwayland \
          --key XwaylandEisNoPrompt \
          true
      '';
    };
  };

  xdg.configFile = {
    # Disable the screen locker entirely — this is an HTPC, not a desktop.
    # Without this, the session locks after inactivity and requires a keyboard
    # to unlock, which breaks the TV remote / controller workflow.
    "kscreenlockerrc".text = ''
      [Daemon]
      Autolock=false
      LockOnResume=false
    '';

    # Disable KDE power management screen-off/dimming.
    # On an HTPC the OS should not black out the screen; the TV handles sleep.
    "powermanagementprofilesrc".text = ''
      [AC][DPMSControl]
      idleTime=0
      lockBeforeTurnOff=0

      [AC][DimDisplay]
      idleTime=0

      [AC][HandleButtonEvents]
      lidAction=0
      triggerLidActionWhenExternalMonitorPresent=false
    '';
  };
}
