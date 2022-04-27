{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nix
    mc
    subversion
    neofetch
    htop
    colordiff
    openssh
    curl
    wget
    ansible
  ];

  programs = {
    git = {
      enable = true;
      userName = "Michał Mieszczak";
      userEmail = "michal@mieszczak.com.pl";
    };
  };
}
