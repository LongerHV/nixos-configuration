{ config, lib, ... }:

let
  cfg = config.homelab.backups;
  mkServiceBackup = name: settings: {
    initialize = true;
    repository = "${cfg.bucket}/${name}";
    timerConfig = {
      OnCalendar = "00:00";
      RandomizedDelaySec = "4h";
    };
    inherit (cfg) pruneOpts passwordFile environmentFile;
  } // settings;
in
{
  options.homelab.backups = with lib; {
    enable = mkEnableOption "backups";
    bucket = mkOption {
      type = types.str;
    };
    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
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
