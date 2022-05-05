{ pkgs, ... }:

{
  imports = [
    ./config/packages.nix
    ./config/neovim.nix
    ./config/tmux.nix
    ./config/zsh.nix
    ./config/devops.nix
  ];
  home.sessionPath = [ "$HOME/.local/bin" ];
}
