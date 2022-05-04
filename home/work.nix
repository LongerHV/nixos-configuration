{ pkgs, ... }:

{
  imports = [
    ./config/packages.nix
    ./config/neovim.nix
    ./config/tmux.nix
    ./config/zsh.nix
  ];
}
