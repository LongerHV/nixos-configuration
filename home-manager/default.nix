{ pkgs, ... }:

{
  imports = [
    ./config/cli-packages.nix
  ];

  programs = {
    git = {
      enable = true;
      userName = "Michał Mieszczak";
      userEmail = "michal@mieszczak.com.pl";
    };
  };
  home.stateVersion = "21.11";
}
