{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.authelia;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yml" cfg.settings;
in
{
  options.services.authelia = {
    enable = mkEnableOption "authelia";
    package = mkOption {
      default = pkgs.unstable.authelia;
      type = types.package;
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
    systemd.services.authelia = {
      description = "Authelia SSO service";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/authelia" +
          (lib.optionalString (cfg.settings != { }) " --config ${configFile}") +
          (lib.optionalString (cfg.settingsFile != "") " --config ${cfg.settingsFile}");
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
      inherit (cfg) environment;
    };

    users.users."${cfg.user}" = {
      inherit (cfg) group;
      isSystemUser = true;
    };
    users.groups."${cfg.group}" = { };
  };
}
