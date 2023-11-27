{ pkgs, ... }:

{
  mySystem = {
    user = "nixos";
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
  };
  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
  ];
}
