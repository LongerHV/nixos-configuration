{ pkgs, config, ... }:

{
  mySystem = {
    user = "nixos";
    home-manager = {
      enable = true;
      home = ../../home-manager/iso.nix;
    };
  };
  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
  ];
}
