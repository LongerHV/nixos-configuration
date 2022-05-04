{ pkgs, ... }:

{
  imports = [
    ./config/packages.nix
    ./config/neovim.nix
    ./config/tmux.nix
    ./config/zsh.nix
  ];

  programs = {
    git = {
      enable = true;
      userName = "Michał Mieszczak";
      userEmail = "michal@mieszczak.com.pl";
    };
  };
}
