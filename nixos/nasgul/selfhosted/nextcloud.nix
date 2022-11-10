{ config, pkgs, lib, ... }:

let
  inherit (config) myDomain;
  inherit (config.age) secrets;
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  imports = [ ./database.nix ];
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

  networking.nat.internalInterfaces = [ "ve-nextcloud" ];
  systemd.services."container@nextcloud".after = lib.mkForce [ "network.target" "mysql.service" ];

  users = {
    users.nextcloud = {
      uid = 997;
      home = "/var/lib/nextcloud";
      createHome = true;
      group = "nextcloud";
      isSystemUser = true;
    };
    users."${config.mainUser}".extraGroups = [ "nextcloud" ];
    groups.nextcloud = {
      gid = 995;
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

    nginx.virtualHosts."localhost".listen = [{ addr = "127.0.0.1"; port = 8086; }];
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      datadir = "/chonk/nextcloud";
      hostName = "localhost";
      https = true;
      config = {
        dbtype = "mysql";
        dbhost = "localhost:/run/mysqld/mysqld.sock";
        adminpassFile = secrets.nextcloud_admin_password.path;
        extraTrustedDomains = [ "nextcloud.local.${myDomain}" "nextcloud.${myDomain}" ];
        trustedProxies = [ "127.0.0.1" ];
      };
    };
  };
}