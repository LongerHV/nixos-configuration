{ config, pkgs, lib, ... }:

let
  my_domain = "nasgul.lan";
  traefik_router = service:
    {
      rule = "Host(`${service}.${my_domain}`)";
      service = "${service}_service";
    };
  traefik_service = { url, port }:
    {
      loadBalancer = {
        servers = [
          { url = "http://${url}:${builtins.toString port}"; }
        ];
      };
    };
  inherit (config.age) secrets;
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    zfsSupport = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot";
      }
      {
        devices = [ "nodev" ];
        path = "/boot-fallback";
      }
    ];
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;

  networking.hostName = "nasgul";
  networking.hostId = "48392063";

  networking = {
    useDHCP = false;
    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    nameservers = [ "127.0.0.1" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    firewall = {
      allowedTCPPorts = [
        80
        443
        8080 # Traefik
        53 # Blocky
      ];
      allowedUDPPorts = [
        53 # Blocky
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      externalInterface = "eth0";
    };
  };

  age.secrets = {
    cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;
    authelia_jwt_secret = {
      file = ../../secrets/nasgul_authelia_jwt_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_storage_encryption_key = {
      file = ../../secrets/nasgul_authelia_storage_encryption_key.age;
      owner = config.services.authelia.user;
    };
    nextcloud_admin_password = {
      file = ../../secrets/nasgul_nextcloud_admin_password.age;
      owner = "nextcloud";
    };
  };

  users.groups.multimedia = { members = [ config.mainUser ]; };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    authelia
  ];
  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.cache_priv_key.path;
    };
    blocky = {
      enable = true;
      settings = {
        port = 53;
        # Cloudflare and Quad9 upstream DNS servers (maybe change to unbound?)
        upstream.default = [
          "1.1.1.1"
          "9.9.9.9"
        ];
        # Reverse lookup (does this even work?)
        clientLookup = {
          upstream = "192.168.1.1";
        };
        # My custom entries for local network
        customDNS = {
          customTTL = "1h";
          mapping = {
            "nasgul.lan" = "192.168.1.243";
          };
        };
        # Redirect all .lan queries to the router
        conditional = {
          mapping = {
            lan = "192.168.1.1";
          };
        };
      };
    };
    traefik = {
      enable = true;
      group = "docker";
      staticConfigOptions = {
        providers.docker = { };
        entryPoints = {
          web = { address = ":80"; };
          websecure = { address = ":443"; };
        };
        api = {
          insecure = true;
          dashboard = true;
        };
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            bazarr_router = traefik_router "bazarr";
            sonarr_router = traefik_router "sonarr";
            radarr_router = traefik_router "radarr";
            prowlarr_router = traefik_router "prowlarr";
            transmission_router = traefik_router "transmission";
            netdata_router = traefik_router "netdata";
            jellyfin_router = traefik_router "jellyfin";
            cache_router = traefik_router "cache";
            authelia_router = traefik_router "authelia";
            gitea_router = traefik_router "gitea";
            nextcloud_router = traefik_router "nextcloud";
            printer_router = traefik_router "printer";
          };
          services = {
            bazarr_service = traefik_service { url = "localhost"; port = 6767; };
            sonarr_service = traefik_service { url = "localhost"; port = 8989; };
            radarr_service = traefik_service { url = "localhost"; port = 7878; };
            prowlarr_service = traefik_service { url = "localhost"; port = 9696; };
            transmission_service = traefik_service { url = "localhost"; port = 9091; };
            netdata_service = traefik_service { url = "localhost"; port = 19999; };
            jellyfin_service = traefik_service { url = "localhost"; port = 8096; };
            cache_service = traefik_service { url = "localhost"; port = 5000; };
            authelia_service = traefik_service { url = "localhost"; port = 9092; };
            gitea_service = traefik_service { url = "localhost"; port = 3000; };
            nextcloud_service = traefik_service { url = "192.168.2.10"; port = 80; };
            printer_service = traefik_service { url = "192.168.1.183"; port = 80; };
          };
        };
      };
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    mysql = {
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
    jellyfin = { enable = true; group = "multimedia"; };
    sonarr = { enable = true; group = "multimedia"; };
    radarr = { enable = true; group = "multimedia"; };
    bazarr = { enable = true; group = "multimedia"; };
    prowlarr = { enable = true; };
    netdata = {
      enable = true;
      config.global = {
        "update every" = "15";
      };
    };
    transmission = {
      enable = true;
      group = "multimedia";
      home = "/chonk/media/torrent";
      downloadDirPermissions = "775";
      settings = {
        umask = 2;
        rpc-authentication-required = false;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = "transmission.${my_domain}";
      };
    };
    gitea = {
      enable = true;
      repositoryRoot = "/chonk/repositories";
      database = {
        type = "mysql";
        socket = "/run/mysqld/mysqld.sock";
      };
    };
    authelia = {
      enable = true;
      jwtSecretFile = config.age.secrets.authelia_jwt_secret.path;
      storageEncryptionKeyFile = config.age.secrets.authelia_storage_encryption_key.path;
      settings = {
        theme = "dark";
        default_2fa_method = "totp";
        server = {
          host = "0.0.0.0";
          port = 9092;
          path = "";
        };
        session = {
          name = "authelia-session";
          domain = "nasgul.lan";
        };
        authentication_backend = {
          file = {
            path = "${config.services.authelia.dataDir}/users_database.yml";
            password = {
              algorithm = "argon2id";
              iterations = 1;
              key_length = 32;
              salt_length = 16;
              memory = 1024;
              parallelism = 8;
            };
          };
        };
        access_control = {
          default_policy = "deny";
          networks = [
            {
              name = "internal";
              networks = [ "192.168.1.0/24" ];
            }
          ];
          rules = [
            {
              domain = "*.lan";
              policy = "one_factor";
              networks = [ "internal" ];
            }
          ];
        };
        storage = {
          local = {
            path = "${config.services.authelia.dataDir}/db.sqlite3";
          };
        };
        notifier = {
          filesystem = {
            filename = "${config.services.authelia.dataDir}/notification.txt";
          };
        };
      };
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
          hostName = "nextcloud.${my_domain}";
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
  system.stateVersion = "21.05";
}

