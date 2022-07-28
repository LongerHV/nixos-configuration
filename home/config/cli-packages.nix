{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs.unstable; [
    cht-sh
    colordiff
    curl
    file
    htop
    jq
    mc
    neofetch
    openssh
    subversion
    tree
    unzip
    wget

    pkgs.poetry
  ];

  programs = {
    gh = {
      enable = true;
    };
  };
}

