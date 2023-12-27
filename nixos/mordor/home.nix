{ pkgs, ... }:

{
  home.stateVersion = "21.11";

  myHome = {
    gnome.enable = true;
    tmux.enable = true;
    zsh.enable = true;
    helix.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };

  home.packages = with pkgs; [
    brave
    jellyfin-media-player
    protonup
    signal-desktop
    super-slicer-latest
    # orca-slicer

    gnomeExtensions.tray-icons-reloaded
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  xdg.configFile."wireplumber/main.lua.d" = {
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
