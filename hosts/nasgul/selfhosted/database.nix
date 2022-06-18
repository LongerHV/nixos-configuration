{ config, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    dataDir = "/chonk/database";
    settings.mysqld.innodb_read_only_compressed = 0;
    ensureDatabases = [
      "authelia"
      "gitea"
    ];
    ensureUsers = [
      {
        name = config.services.authelia.user;
        ensurePermissions = {
          "authelia.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = config.services.gitea.database.user;
        ensurePermissions = {
          "gitea.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
