{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia;
  opt = options.services.authelia;
  rootDir = "/var/lib/authelia";
  configFile = pkgs.writeTextFile {
    name = "configuration.yml";
    text = builtins.toJSON cfg.settings;
  };
in
{
  options.services.authelia = {
    enable = mkEnableOption "authelia";
    dataDir = mkOption {
      default = "/var/lib/authelia";
      type = types.path;
    };
    jwtSecretFile = mkOption {
      type = types.path;
    };
    storageEncryptionKeyFile = mkOption {
      type = types.path;
    };
    settings = mkOption {
      type = types.attrs;
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
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0700 authelia authelia - -" ];
    systemd.services.authelia = {
      description = "Authelia SSO service";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.authelia}/bin/authelia --config ${configFile}";
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
      environment = {
        AUTHELIA_JWT_SECRET_FILE = cfg.jwtSecretFile;
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = cfg.storageEncryptionKeyFile;
      };
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
