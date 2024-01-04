{ config, lib, pkgs, ... }:

let
  cfg = config.services.homepage;
  format = pkgs.formats.yaml { };
  configFile = format.generate "conf.yml" cfg.settings;
  configDir = "${cfg.dataDir}/config";
in
{
  options.services.homepage = with lib; {
    enable = mkEnableOption "homepage";
    package = mkOption {
      type = types.package;
      default = pkgs.homepage;
    };
    port = mkOption {
      type = types.port;
      default = 4001;
    };
    user = mkOption {
      type = types.str;
      default = "homepage";
    };
    group = mkOption {
      type = types.str;
      default = "homepage";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/homepage";
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${cfg.user}" = {
      inherit (cfg) group;
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups."${cfg.group}" = { };
    systemd.services.homepage = {
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${configDir}
        ln -sf ${configFile} ${configDir}/settings.yaml
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/homepage";
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
      };
      environment = {
        PORT = builtins.toString cfg.port;
        HOMEPAGE_CONFIG_DIR = configDir;
      };
    };
  };
}
