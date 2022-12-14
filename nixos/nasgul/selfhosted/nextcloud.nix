{ config, pkgs, lib, ... }:

let
  inherit (config) myDomain;
  inherit (config.age) secrets;
  util = pkgs.callPackage ./util.nix { inherit config; };
  cfg = config.services.nextcloud;
in
{
  services.traefik.dynamicConfigOptions.http = {
    middlewares.nextcloud-redirectregex.redirectRegex = {
      permanent = true;
      regex = "https://(.*)/.well-known/(card|cal)dav";
      replacement = "https://\${1}/remote.php/dav/";
    };
    routers.nextcloud_router = util.traefik_router {
      subdomain = "nextcloud";
      middlewares = [ "nextcloud-redirectregex" ];
    };
    services.nextcloud_service = util.traefik_service { url = "localhost"; port = 8086; };
  };

  age.secrets = {
    nextcloud_admin_password = {
      file = ../../../secrets/nasgul_nextcloud_admin_password.age;
      owner = "nextcloud";
    };
  };

  services = {
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

    nginx.virtualHosts."${cfg.hostName}".listen = [{ addr = "127.0.0.1"; port = 8086; }];
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud25;
      enableBrokenCiphersForSSE = false;
      datadir = "/chonk/nextcloud";
      hostName = "nextcloud.local.${myDomain}";
      https = true;
      config = {
        dbtype = "mysql";
        dbhost = "localhost:/run/mysqld/mysqld.sock";
        adminpassFile = secrets.nextcloud_admin_password.path;
        trustedProxies = [ "127.0.0.1" ];
      };
    };
  };
  systemd.services = lib.genAttrs [ "nextcloud-setup" "nextcloud-cron" ] (_: {
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
  });
}
