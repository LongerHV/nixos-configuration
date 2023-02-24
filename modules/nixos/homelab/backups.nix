{ config, lib, ... }:

let
  cfg = config.homelab.backups;
  mkServiceBackup = name: settings: {
    initialize = true;
    repository = "${cfg.bucket}/${name}";
    inherit (cfg) passwordFile environmentFile;
  } // settings;
in
{
  options.homelab.backups = with lib; {
    enable = mkEnableOption "backups";
    bucket = mkOption {
      type = types.str;
    };
    passwordFile = mkOption {
      type = types.str;
    };
    environmentFile = mkOption {
      type = types.str;
    };
    services = mkOption {
      type = types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.restic = { };
    services.restic.backups = builtins.mapAttrs mkServiceBackup cfg.services;
  };
}
