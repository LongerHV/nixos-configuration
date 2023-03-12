{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  cfg = hl.nextcloud;
  inherit (config.services) nextcloud;
  redis = config.services.redis.servers."";
  port = 8086;
  datadir = "${hl.storage}/nextcloud";
  hostName = "nextcloud.${hl.domain}";
in
{
  options.homelab.nextcloud = with lib; {
    enable = mkEnableOption "nextcloud";
    package = lib.mkOption {
      type = lib.types.package;
    };
    adminpassFile = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.nextcloud.extraGroups = [ "redis" "restic" ];

    systemd = {
      tmpfiles.rules = [
        "d ${datadir} 750 nextcloud nextcloud - -"
      ];
      services = lib.genAttrs [ "nextcloud-setup" "nextcloud-cron" ] (_: {
        after = [ "mysql.service" "redis.service" ];
        requires = [ "mysql.service" "redis.service" ];
      });
    };

    homelab = {
      mysql.enable = true;
      redis.enable = true;
      traefik = {
        enable = true;
        services.nextcloud = { inherit port; middlewares = [ "nextcloud-redirectregex" ]; };
      };
      backups.services.nextcloud =
        let
          occ = "${nextcloud.occ}/bin/nextcloud-occ";
        in
        {
          user = "nextcloud";
          backupPrepareCommand = ''
            ${occ} maintenance:mode --on
            ${hl.mysql.package}/bin/mysqldump --databases nextcloud > /tmp/nextcloud.sql
          '';
          backupCleanupCommand = ''
            ${occ} maintenance:mode --off
            rm /tmp/nextcloud.sql
          '';
          paths = [ datadir nextcloud.home "/tmp/nextcloud.sql" ];
        };
    };

    services = {
      traefik.dynamicConfigOptions.http.middlewares.nextcloud-redirectregex.redirectRegex = {
        permanent = true;
        regex = "https://(.*)/.well-known/(card|cal)dav";
        replacement = "https://\${1}/remote.php/dav/";
      };

      mysql = {
        settings.mysqld.innodb_read_only_compressed = 0;
        ensureDatabases = [
          "nextcloud"
        ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensurePermissions = {
              "nextcloud.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      nginx.virtualHosts."${hostName}".listen = [{ addr = "127.0.0.1"; inherit port; }];
      nextcloud = {
        enable = true;
        inherit (cfg) package;
        enableBrokenCiphersForSSE = false;
        inherit datadir hostName;
        https = true;
        config = {
          dbtype = "mysql";
          dbhost = "localhost:/run/mysqld/mysqld.sock";
          trustedProxies = [ "127.0.0.1" ];
          inherit (cfg) adminpassFile;
        };
        caching = {
          redis = true;
          apcu = false;
        };
        extraOptions = {
          "memcache.local" = "\\OC\\Memcache\\Redis";
          "memcache.locking" = "\\OC\\Memcache\\Redis";
          redis = {
            host = redis.unixSocket;
            port = 0;
            dbindex = 3;
            timeout = 1.5;
          };
        };
      };
    };
  };
}
