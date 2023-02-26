{ lib, ... }:

{
  imports = [
    ./config/gnome.nix
  ];

  home = rec {
    username = "mmieszczak";
    homeDirectory = "/home/${username}";
    stateVersion = "22.05";
  };

  myHome = {
    nonNixos.enable = true;
    devops.enable = true;
    cli.personalGitEnable = false;
    tmux.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };
}
