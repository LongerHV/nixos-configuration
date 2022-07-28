{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs.unstable; [
    mc
    subversion
    neofetch
    htop
    colordiff
    openssh
    curl
    wget
    file
    tree
    jq
    unzip
    cht-sh
    pkgs.poetry
  ];

  programs = {
    gh = {
      enable = true;
    };
  };
}

