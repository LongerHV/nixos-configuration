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
    jq
    cht-sh
    poetry
  ];
}
