{ pkgs, ... }:

{
  imports = [ ];
  home.packages = with pkgs; [
    neofetch
    htop
    mc
    colordiff
    openssh
    curl
    wget
    ansible
  ];

  programs.git = {
    enable = true;
    userName = "Michał Mieszczak";
    userEmail = "michal@mieszczak.com.pl";
  };
}
