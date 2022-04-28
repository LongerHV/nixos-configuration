{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hostname
    unstable.home-manager
    unstable.nix
  ];
}
