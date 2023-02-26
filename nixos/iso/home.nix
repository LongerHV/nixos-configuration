_:

{
  home.stateVersion = "21.11";
  imports = [
    ../../home-manager/config/gui-packages.nix
  ];

  myHome = {
    tmux.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };
}
