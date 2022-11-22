{ config, lib, ... }:

let
  cfg = config.homelab.mysql;
in
{
  options.homelab.mysql = {
    enable = lib.mkEnableOption "mysql";
  };
  config = lib.mkIf cfg.enable {
    services.mysql = {
      enable = true;
      dataDir = "${config.homelab.storage}/database";
    };
  };
}
