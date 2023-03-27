{ config, lib, pkgs, ... }:

let
  cfg = config.services.lldap;
  format = pkgs.formats.toml { };
  configFile = format.generate "lldap_config.yml" cfg.settings;
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
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
    environment = mkOption {
      type = types.attrs;
      default = { };
    };
    user = mkOption {
      default = "lldap";
      type = types.str;
    };
    group = mkOption {
      default = "lldap";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.lldap = {
      description = "Lightweight LDAP server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ln -sfT ${cfg.web} /var/lib/lldap/app
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/lldap run --config-file ${configFile}";
        WorkingDirectory = "/var/lib/lldap";
        User = cfg.user;
        Group = cfg.group;
      };
      inherit (cfg) environment;
    };

    users.users."${cfg.user}" = {
      inherit (cfg) group;
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/lldap";
    };
    users.groups."${cfg.group}" = { };
  };
}
