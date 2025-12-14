{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  cfg = hl.nextcloud;
  inherit (config.services) nextcloud;
  port = 8086;
  datadir = "${hl.storage}/nextcloud";
  hostName = "nextcloud.${hl.domain}";
  occ = "${nextcloud.occ}/bin/nextcloud-occ";
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
    tmpdir = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users.users.nextcloud.extraGroups = [ "restic" ];
      users.users.${config.mySystem.user}.extraGroups = [ "nextcloud" ];
      environment.systemPackages = [ pkgs.ffmpeg ];

      systemd = {
        tmpfiles.rules = [
          "d ${datadir} 750 nextcloud nextcloud - -"
        ];
        services = lib.genAttrs [ "nextcloud-setup" "nextcloud-cron" ] (_: {
          after = [ "mysql.service" "redis-nextcloud.service" ];
          requires = [ "mysql.service" "redis-nextcloud.service" ];
        });
      };

      homelab = {
        mysql.enable = true;
        redis.enable = true;
        traefik = {
          enable = true;
          services.nextcloud = { inherit port; middlewares = [ "nextcloud-redirectregex" ]; };
          services.collabora = { inherit (config.services.collabora-online) port; };
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
          inherit datadir hostName;
          https = true;
          appstoreEnable = true;
          extraAppsEnable = true;
          extraApps = with cfg.package.packages.apps; {
            inherit richdocuments;
          };
          config = {
            dbtype = "mysql";
            dbhost = "localhost:/run/mysqld/mysqld.sock";
            inherit (cfg) adminpassFile;
          };
          caching = {
            redis = true;
            apcu = true;
          };
          phpOptions = {
            memory_limit = lib.mkForce "2048M";
            "opcache.interned_strings_buffer" = "64";
          };
          phpExtraExtensions = all: [ all.pdlib all.bz2 ];
          settings = {
            default_phone_region = "PL";
            trusted_proxies = [ "127.0.0.1" ];
            "memcache.local" = "\\OC\\Memcache\\APCu";
            "memcache.distributed" = "\\OC\\Memcache\\Redis";
            "memcache.locking" = "\\OC\\Memcache\\Redis";
            # Redis is now auto-configured by the Nextcloud module (dedicated instance)
          };
        };

        collabora-online = {
          enable = true;
          port = 9980;
          settings = {
            ssl = {
              enable = false;
              termination = true;
            };
            storage.wopi = {
              "@allow" = true;
              host = [ hostName ];
            };
            server_name = "collabora.${hl.domain}";
          };
        };
      };
      networking.hosts."127.0.0.1" = [ "collabora.${hl.domain}" "nextcloud.${hl.domain}" ];
    }
    (lib.mkIf hl.backups.enable {
      homelab.backups.services.nextcloud = {
        user = "nextcloud";
        backupPrepareCommand = /* bash */''
          ${occ} maintenance:mode --on
          ${hl.mysql.package}/bin/mysqldump --databases nextcloud > /tmp/nextcloud.sql
        '';
        backupCleanupCommand = /* bash */ ''
          ${occ} maintenance:mode --off
          rm /tmp/nextcloud.sql
        '';
        paths = [ datadir nextcloud.home "/tmp/nextcloud.sql" ];
      };
    })
    (lib.mkIf (cfg.tmpdir != null) (with cfg; {
      services.nextcloud.settings.tempdirectory = tmpdir;
      services.phpfpm.pools.nextcloud.phpEnv = {
        TMP = tmpdir;
        TEMP = tmpdir;
        TMPDIR = tmpdir;
      };
    }))
  ]);
}
