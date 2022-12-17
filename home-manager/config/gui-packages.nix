{ pkgs, ... }:

{
  imports = [ ./alacritty.nix ./gnome.nix ];

  home.packages = with pkgs; [
    brave
    signal-desktop
  ];
}
