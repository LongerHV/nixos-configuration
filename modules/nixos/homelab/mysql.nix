{ config, lib, ... }:

let
  cfg = config.homelab.mysql;
in
{
  options.homelab.mysql = {
    enable = lib.mkEnableOption "mysql";
    package = lib.mkOption {
      type = lib.types.package;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${config.homelab.storage}/database 750 ${config.services.mysql.user} ${config.services.mysql.group} - -"
    ];

    services.mysql = {
      inherit (cfg) enable package;
      dataDir = "${config.homelab.storage}/database";
    };
  };
}
