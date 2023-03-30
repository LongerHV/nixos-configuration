{ config, lib, pkgs, ... }:

let
  cfg = config.services.lldap;
  format = pkgs.formats.toml { };
  configFile = format.generate "lldap_config.yml" cfg.settings;
  dataDir = "/var/lib/lldap";
in
{
  options.services.lldap = with lib; {
    enable = mkEnableOption "lldap";
    package = mkOption {
      default = pkgs.lldap;
      type = types.package;
    };
    web = mkOption {
      default = pkgs.lldap.web;
      type = types.package;
    };
    environment = mkOption {
      type = types.attrs;
      default = { };
      example = ''
        {
          LLDAP_JWT_SECRET_FILE = "/run/lldap/jwt_secret";
          LLDAP_LDAP_USER_PASS_FILE = "/run/lldap/user_password";
        }
      '';
    };
    user = mkOption {
      default = "lldap";
      type = types.str;
    };
    group = mkOption {
      default = "lldap";
      type = types.str;
    };
    settings = mkOption {
      default = { };
      type = types.submodule {
        freeformType = format.type;
        options = {
          verbose = mkOption {
            type = types.bool;
            description = "Tune the logging to be more verbose by setting this to be true";
            default = false;
          };
          ldap_host = mkOption {
            type = types.str;
            description = "The host address that the LDAP server will be bound to";
            default = "0.0.0.0";
          };
          ldap_port = mkOption {
            type = types.port;
            description = "The port on which to have the LDAP server";
            default = 3890;
          };
          http_host = mkOption {
            type = types.str;
            description = "The host address that the HTTP server will be bound to";
            default = "0.0.0.0";
          };
          http_port = mkOption {
            type = types.port;
            description = "The port on which to have the HTTP server, for user login and administration";
            default = 17170;
          };
          http_url = mkOption {
            type = types.str;
            description = "The public URL of the server, for password reset links";
            default = "http://localhost";
          };
          ldap_base_dn = mkOption {
            type = types.str;
            description = "Base DN for LDAP";
            default = "dc=example,dc=com";
          };
          ldap_user_dn = mkOption {
            type = types.str;
            description = "Admin username";
            default = "admin";
          };
          ldap_user_email = mkOption {
            type = types.str;
            description = "Admin email";
            default = "admin@example.com";
          };
          database_url = mkOption {
            type = types.str;
            description = "Database URL";
            default = "sqlite:///${dataDir}/users.db?mode=rwc";
            example = "mysql://mysql-user:password@mysql-server/my-database";
          };
          key_file = mkOption {
            type = types.str;
            description = "Private key file";
            default = "${dataDir}/private_key";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.lldap = {
      description = "Lightweight LDAP server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ln -sfT ${cfg.web} ${dataDir}/app
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/lldap run --config-file ${configFile}";
        WorkingDirectory = dataDir;
        User = cfg.user;
        Group = cfg.group;
      };
      inherit (cfg) environment;
    };

    users.users."${cfg.user}" = {
      inherit (cfg) group;
      isSystemUser = true;
      createHome = true;
      home = dataDir;
    };
    users.groups."${cfg.group}" = { };
  };
}
