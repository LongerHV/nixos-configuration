{ pkgs, ... }:

{
  imports = [ ./alacritty.nix ./gnome.nix ];

  home.packages = with pkgs.unstable; [
    brave
    signal-desktop
  ];
}
