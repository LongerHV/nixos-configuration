{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    mc
    subversion
    neofetch
    htop
    colordiff
    openssh
    curl
    wget
  ];
}
