{ config, lib, ... }:

let
  cfg = config.homelab.redis;
in
{
  options.homelab.redis = {
    enable = lib.mkEnableOption "redis";
    databases = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
  };
  config = lib.mkIf cfg.enable {
    services.redis.servers."" = {
      enable = true;
      inherit (cfg) databases;
      port = 0;
    };
  };
}
