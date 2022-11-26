{ pkgs, config, ... }:

{
  mySystem.user = "nixos";
  home-manager.users."${config.mySystem.user}" = import ../../home-manager/iso.nix;
  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
  ];
}
