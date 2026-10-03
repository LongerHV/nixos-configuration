{ pkgs, ... }:

{
  home.stateVersion = "21.11";

  myHome = {
    gnome.enable = true;
    tmux.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
    music-production.enable = true;
  };

  home.packages = with pkgs; [
    anki-bin
    brave
    jazz2
    jellyfin-media-player
    protonup-ng
    signal-desktop
    freecad
    prusa-slicer

    gnomeExtensions.tray-icons-reloaded
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # gcr-ssh-agent cannot drive FIDO2 keys, so bypass it and use the key handles directly.
      # ControlMaster reuses one connection so a deploy needs a single touch.
      # Only root (deploy-rs) logins; regular logins keep using the agent.
      deploy-targets = {
        match = "user root host nasgul.lan,smaug.lan,isildur.lan,anarion.lan,palantir.lan,angmar.lan";
        identityFile = [
          "~/.ssh/id_ed25519_sk_rk_yubi"
          "~/.ssh/id_ed25519_sk_rk_yubi_backup"
        ];
        identitiesOnly = true;
        controlMaster = "auto";
        controlPath = "~/.ssh/control-%C";
        controlPersist = "5m";
        extraOptions.IdentityAgent = "none";
      };
    };
  };

  xdg.configFile."wireplumber/wireplumber.conf.d" = {
    recursive = true;
    source = ./wireplumber;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "gsconnect@andyholmes.github.io"
        "trayIconsReloaded@selfmade.pl"
      ];
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Shift><Control><Super>l" ];
    };
  };
}
