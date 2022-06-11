{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
  ];
}
