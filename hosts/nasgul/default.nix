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

  users.groups.multimedia = { members = [ "longer" ]; };

  virtualisation.docker.enable = true;

  services = {
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
            # nextcloud_router = traefik_router "nextcloud";
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
            # nextcloud_service = traefik_service { url = "192.168.100.11"; port = 80; };
            printer_service = traefik_service { url = "192.168.1.183"; port = 80; };
          };
        };
      };
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    # mysql = {
    #   enable = true;
    #   package = pkgs.mariadb;
    # };
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
  };

  # containers = {
  #   nextcloud = {
  #     ephemeral = true;
  #     autoStart = true;
  #     privateNetwork = true;
  #     hostAddress = "192.168.100.2";
  #     localAddress = "192.168.100.11";
  #     config = { config, pkgs, ... }: {
  #       networking.firewall.allowedTCPPorts = [ 80 ];
  #       services.nextcloud = {
  #         enable = true;
  #         package = pkgs.nextcloud22;
  #         hostName = "nextcloud.${my_domain}";
  #         config.adminpassFile = "/etc/nextcloudpass";
  #       };
  #     };
  #     forwardPorts = [
  #       {
  #         containerPort = 80;
  #         hostPort = 81;
  #         protocol = "tcp";
  #       }
  #     ];
  #     bindMounts = {
  #       "/etc/nextcloudpass" = {
  #         hostPath = "/etc/nextcloudpass";
  #         isReadOnly = true;
  #       };
  #       "/var/lib/nextcloud" = {
  #         hostPath = "/var/lib/nextcloud";
  #         # hostPath = "/chonk/nextcloud";
  #         isReadOnly = false;
  #       };
  #     };
  #   };
  # };
  system.stateVersion = "21.05";
}

