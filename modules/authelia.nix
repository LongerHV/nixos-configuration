{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia;
  rootDir = "/var/lib/authelia";
  storeConfigFile = pkgs.writeTextFile {
    name = "configuration.yml";
    text = builtins.toJSON cfg.settings;
  };
  configPath = "${cfg.dataDir}/configuration.yml";
  preStart =
    if cfg.settingsFile != "" then
      "${pkgs.jq}/bin/jq -s '.[0] * .[1]' ${storeConfigFile} ${cfg.settingsFile} > ${configPath} && chown authelia:authelia ${configPath} && chmod 600 ${configPath}"
    else "cp ${storeConfigFile} ${configPath}";
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
    mysqlPasswordFile = mkOption {
      type = types.path;
    };
    oidcHmacSecretFile = mkOption {
      type = types.path;
    };
    oidcIssuerPrivKeyFile = mkOption {
      type = types.path;
    };
    sessionSecretFile = mkOption {
      type = types.path;
    };
    ldapPasswordFile = mkOption {
      type = types.path;
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
      environment = {
        AUTHELIA_JWT_SECRET_FILE = cfg.jwtSecretFile;
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = cfg.storageEncryptionKeyFile;
        AUTHELIA_STORAGE_MYSQL_PASSWORD_FILE = cfg.mysqlPasswordFile;
        AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE = cfg.oidcHmacSecretFile;
        AUTHELIA_IDENTITY_PROVIDERS_OIDC_ISSUER_PRIVATE_KEY_FILE = cfg.oidcIssuerPrivKeyFile;
        AUTHELIA_SESSION_SECRET_FILE = cfg.sessionSecretFile;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = cfg.ldapPasswordFile;
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
