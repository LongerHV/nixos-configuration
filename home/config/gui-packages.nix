{ pkgs, lib, ... }:

{
  imports = [ ./alacritty.nix ];

  home.packages = with pkgs.unstable; [
    inconsolata-nerdfont
    brave
    signal-desktop
  ];

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
