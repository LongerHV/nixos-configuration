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
}
