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
  };

  home.packages = with pkgs; [
    brave
    freecad
    openscad
    protonup
    qmk
    reaper
    signal-desktop
    super-slicer-latest
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
