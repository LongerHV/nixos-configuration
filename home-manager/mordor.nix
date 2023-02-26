{ pkgs, ... }:

{
  home.stateVersion = "21.11";
  imports = [
    ./default.nix
    ./config/gui-packages.nix
    ./config/printing.nix
  ];

  myHome = {
    tmux.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };

  home.packages = with pkgs; [
    reaper
    qmk
    protonup
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
