{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs.unstable; [
    bat
    cht-sh
    colordiff
    curl
    exa
    file
    htop
    jq
    lazygit
    mc
    neofetch
    openssh
    spotify-tui
    subversion
    tree
    unzip
    wget

    pkgs.poetry
  ];

  programs = {
    gh.enable = true;
    zsh.shellAliases = {
      lg = "lazygit";
    };
  };
}

