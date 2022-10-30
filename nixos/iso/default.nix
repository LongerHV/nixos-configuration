{ pkgs, config, ... }:

{
  mainUser = "nixos";
  home-manager.users."${config.mainUser}" = import ../../home-manager/iso.nix;
  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
  ];
}
