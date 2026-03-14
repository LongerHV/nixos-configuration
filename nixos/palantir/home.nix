{ pkgs, ... }:

{
  home.stateVersion = "25.11";
  myHome = {
    gnome.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = false;
    };
  };

  home.packages = with pkgs; [
    brave
    spotify
    jellyfin-media-player
    gnomeExtensions.tray-icons-reloaded
  ];
}
