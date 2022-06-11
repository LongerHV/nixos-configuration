{ pkgs, ... }:

{
  imports = [ ./alacritty.nix ./dconf.nix ];

  home.packages = with pkgs.unstable; [
    brave
    signal-desktop
  ];
}
