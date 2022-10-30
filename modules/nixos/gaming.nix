{ config, lib, ... }:

let
  cfg = config.custom.gaming;
in
{
  options = {
    custom.gaming.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
      gamemode.enable = true;
    };
  };
}
