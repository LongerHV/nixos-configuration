{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = config.services.immich;
  dataDir = "${config.homelab.storage}/immich";
in
{
  config = lib.mkMerge [
    {
      homelab.traefik.services.immich.port = cfg.port;
      services.immich = {
        enable = true;
        mediaLocation = "${config.homelab.storage}/immich";
      };
      systemd.tmpfiles.rules = [
        "d ${dataDir} 750 ${cfg.user} ${cfg.group} - -"
        "d ${dataDir}/database-backup 750 ${cfg.user} ${cfg.group} - -"
      ];
    }

    (lib.mkIf hl.backups.enable {
      users.users."${cfg.user}".extraGroups = [ "restic" ];
      homelab.backups.services.immich = {
        inherit (cfg) user;
        backupPrepareCommand = /* bash */ ''
          ${config.services.postgresql.package}/bin/pg_dump --clean --if-exists --dbname=${cfg.database.name} > "${dataDir}"/database-backup/immich-database.sql
        '';
        paths = [
          "${dataDir}/library"
          "${dataDir}/profile"
          "${dataDir}/upload"
          "${dataDir}/database-backup"
        ];
      };
    })
  ];
}
