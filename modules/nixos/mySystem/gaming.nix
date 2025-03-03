{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.gaming;
in
{
  options.mySystem.gaming = {
    enable = lib.mkEnableOption "gaming";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.lutris.override { extraLibraries = p: with p; [ libadwaita gtk4 ]; })
      pkgs.protonup-ng
      pkgs.wine
    ];
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
      gamemode.enable = true;
      sunshine.enable = true;
      corectrl = {
        enable = true;
        gpuOverclock.enable = true;
      };
    };
  };
}
