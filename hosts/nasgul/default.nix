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
  imports =
    [
      ../hosts-common.nix
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
  ];

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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
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
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    firewall = {
      allowedTCPPorts = [
        80
        443
        8080
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      externalInterface = "eth0";
    };
  };

  users.users.longer.extraGroups = [ "multimedia" ];
  users.groups."docker".members = [ "traefik" ];
  users.groups."multimedia" = { };

  services = {
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
            # jackett_router = traefik_router "jackett";
            transmission_router = traefik_router "transmission";
            netdata_router = traefik_router "netdata";
            grafana_router = traefik_router "grafana";
            prometheus_router = traefik_router "prometheus";
            jellyfin_router = traefik_router "jellyfin";
            nextcloud_router = traefik_router "nextcloud";
            printer_router = traefik_router "printer";
          };
          services = {
            transmission_service = traefik_service { url = "localhost"; port = 9091; };
            bazarr_service = traefik_service { url = "localhost"; port = 6767; };
            sonarr_service = traefik_service { url = "localhost"; port = 8989; };
            radarr_service = traefik_service { url = "localhost"; port = 7878; };
            prowlarr_service = traefik_service { url = "localhost"; port = 9696; };
            # jackett_service = traefik_service { url = "localhost"; port = 9117; };
            netdata_service = traefik_service { url = "localhost"; port = 19999; };
            grafana_service = traefik_service { url = "localhost"; port = 3000; };
            prometheus_service = traefik_service { url = "localhost"; port = 9090; };
            jellyfin_service = traefik_service { url = "localhost"; port = 8096; };
            nextcloud_service = traefik_service { url = "192.168.100.11"; port = 80; };
            printer_service = traefik_service { url = "192.168.1.183"; port = 80; };
          };
        };
      };
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    jellyfin = { enable = true; group = "multimedia"; };
    sonarr = { enable = true; group = "multimedia"; };
    radarr = { enable = true; group = "multimedia"; };
    bazarr = { enable = true; group = "multimedia"; };
    prowlarr = { enable = true; };
    # jackett = { enable = true; group = "multimedia"; };
    netdata = {
      enable = true;
      config.global = {
        "update every" = "15";
      };
    };
    prometheus = {
      enable = true;
      exporters = {
        # systemd.enable = true;
        # smartctl.enable = true;
        nextcloud = {
          # enable = true;
          url = "http://nextcloud.${my_domain}";
          passwordFile = /etc/nextcloudpass;
        };
      };
    };
    grafana = {
      enable = true;
      domain = "grafana.${my_domain}";
    };
    transmission = {
      enable = true;
      group = "multimedia";
      home = "/chonk/torrent";
      downloadDirPermissions = "775";
      settings = {
        umask = 0;
        rpc-authentication-required = false;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = "transmission.${my_domain}";
      };
    };
  };

  containers = {
    nextcloud = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.2";
      localAddress = "192.168.100.11";
      config = { config, pkgs, ... }: {
        networking.firewall.allowedTCPPorts = [ 80 ];
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud22;
          hostName = "nextcloud.${my_domain}";
          config.adminpassFile = "/etc/nextcloudpass";
        };
      };
      forwardPorts = [
        {
          containerPort = 80;
          hostPort = 81;
          protocol = "tcp";
        }
      ];
      bindMounts = {
        "/etc/nextcloudpass" = {
          hostPath = "/etc/nextcloudpass";
          isReadOnly = true;
        };
        "/var/lib/nextcloud" = {
          hostPath = "/var/lib/nextcloud";
          # hostPath = "/chonk/nextcloud";
          isReadOnly = false;
        };
      };
    };
  };
  system.stateVersion = "21.05";
}

