{ config, lib, pkgs, ... }:

let
  cfg = config.services.dashy;
  format = pkgs.formats.yaml { };
  configFile = format.generate "conf.yml" cfg.settings;
in
{
  options.services.dashy = with lib; {
    enable = mkEnableOption "dashy";
    package = mkOption {
      type = types.package;
      default = pkgs.dashy;
    };
    port = mkOption {
      type = types.int;
      default = 4000;
    };
    user = mkOption {
      type = types.str;
      default = "dashy";
    };
    group = mkOption {
      type = types.str;
      default = "dashy";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/dashy";
    };
    mutableConfig = mkOption {
      type = types.bool;
      default = false;
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
    systemd.services.dashy = {
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.dataDir}/public
      '' + (if cfg.mutableConfig then ''
        if [ ! -f ${cfg.dataDir}/public/conf.yml ]; then
          cp ${cfg.package}/libexec/Dashy/deps/Dashy/public/conf.yml ${cfg.dataDir}/public/conf.yml
          chmod u+w ${cfg.dataDir}/public/conf.yml
        fi
      '' else ''
        ln -sf ${configFile} ${cfg.dataDir}/public/conf.yml
      '');
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/dashy";
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
      };
      environment = {
        PORT = builtins.toString cfg.port;
      };
    };
  };
}
