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

