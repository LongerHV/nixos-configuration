{ pkgs, lib, ... }:

{
  imports = [ ./alacritty.nix ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs.unstable; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
    brave
    signal-desktop
  ];
}
