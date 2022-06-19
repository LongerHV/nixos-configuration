{ config, pkgs, lib, ... }:

let
  inherit (config) myDomain;
  inherit (config.age) secrets;
  util = pkgs.callPackage ./util.nix { inherit config; };
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
    services.nextcloud_service = util.traefik_service { url = "192.168.2.10"; port = 80; };
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
      group = "nextcloud";
      isSystemUser = true;
    };
    users."${config.mainUser}".extraGroups = [ "nextcloud" ];
    groups.nextcloud = {
      gid = 995;
    };
  };

  containers = {
    nextcloud = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.2.1";
      localAddress = "192.168.2.10";
      config = { config, pkgs, ... }: {
        networking.firewall.allowedTCPPorts = [ 80 ];
        networking.nameservers = [ "192.168.2.1" ];
        networking.dhcpcd.extraConfig = "nohook resolv.conf";
        time.timeZone = "Europe/Warsaw";
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud24;
          hostName = "nextcloud.${myDomain}";
          config = {
            dbtype = "mysql";
            dbhost = "localhost:/run/mysqld/mysqld.sock";
            adminpassFile = secrets.nextcloud_admin_password.path;
            extraTrustedDomains = [ "nextcloud.local.${myDomain}" ];
          };
        };
        users.users.nextcloud = {
          uid = 997;
          home = "/var/lib/nextcloud";
          group = "nextcloud";
          isSystemUser = true;
        };
        users.groups.nextcloud = {
          gid = 995;
        };
        system.stateVersion = "22.05";
      };
      bindMounts = {
        ${secrets.nextcloud_admin_password.path} = {
          hostPath = secrets.nextcloud_admin_password.path;
          isReadOnly = true;
        };
        "/run/mysqld/mysqld.sock" = {
          hostPath = "/run/mysqld/mysqld.sock";
          isReadOnly = false;
        };
        "/var/lib/nextcloud" = {
          hostPath = "/chonk/nextcloud";
          isReadOnly = false;
        };
      };
    };
  };
}
