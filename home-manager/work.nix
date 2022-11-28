{ lib, ... }:

{
  imports = [
    ./config/gnome.nix
    ./config/neovim.nix
    ./config/tmux.nix
    ./config/zsh.nix
  ];

  home = rec {
    username = "mmieszczak";
    homeDirectory = "/home/${username}";
    stateVersion = "22.05";
  };

  myHome = {
    nonNixos.enable = true;
    cli = {
      devops.enable = true;
      personalGitEnable = false;
    };
  };
}
