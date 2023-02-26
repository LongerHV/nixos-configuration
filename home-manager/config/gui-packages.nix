{ pkgs, ... }:

{
  imports = [ ./gnome.nix ];

  home.packages = with pkgs; [
    brave
    signal-desktop
  ];
}
