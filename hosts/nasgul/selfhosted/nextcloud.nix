{ config, pkgs, ... }:

let
  inherit (config) myDomain;
  inherit (config.age) secrets;
in
{
  age.secrets = {
    nextcloud_admin_password = {
      file = ../../../secrets/nasgul_nextcloud_admin_password.age;
      owner = "nextcloud";
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-*" ];
    externalInterface = "eth0";
  };

  users = {
    users.nextcloud = {
      uid = 997;
      home = "/var/lib/nextcloud";
      group = "nextcloud";
      isSystemUser = true;
    };
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
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud24;
          hostName = "nextcloud.${myDomain}";
          config = {
            dbtype = "mysql";
            dbhost = "localhost:/run/mysqld/mysqld.sock";
            adminpassFile = secrets.nextcloud_admin_password.path;
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
