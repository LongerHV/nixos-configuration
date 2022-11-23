{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia;
  storeConfigFile = pkgs.writeTextFile {
    name = "configuration.yml";
    text = builtins.toJSON cfg.settings;
  };
  configPath = "${cfg.dataDir}/configuration.yml";
  preStart =
    if cfg.settingsFile != "" then ''
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' ${storeConfigFile} ${cfg.settingsFile} > ${configPath}
    '' else ''
      cp ${storeConfigFile} ${configPath}
    '' + ''
      chown authelia:authelia ${configPath}
      chmod 600 ${configPath}"
    '';
in
{
  options.services.authelia = {
    enable = mkEnableOption "authelia";
    dataDir = mkOption {
      default = "/var/lib/authelia";
      type = types.path;
    };
    environment = mkOption {
      type = types.attrs;
      default = { };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
    settingsFile = mkOption {
      type = types.str;
      default = "";
    };
    user = mkOption {
      default = "authelia";
      type = types.str;
    };
    group = mkOption {
      default = "authelia";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -" ];
    systemd.services.authelia = {
      description = "Authelia SSO service";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = "${preStart}";
      serviceConfig = {
        ExecStart = "${pkgs.authelia}/bin/authelia --config ${configPath}";
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
      inherit (cfg) environment;
    };

    users.users."${cfg.user}" = {
      inherit (cfg) group;
      home = cfg.dataDir;
      createHome = true;
      homeMode = "750";
      isSystemUser = true;
    };

    users.groups."${cfg.group}" = { };
  };
}
