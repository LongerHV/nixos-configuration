{ config, ... }:

let
  my_domain = "nasgul.lan";
  traefik_router = service:
    {
      rule = "Host(`${service}.${config.myDomain}`)";
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
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  services.traefik = {
    enable = true;
    # group = "docker";
    staticConfigOptions = {
      # providers.docker = { };
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
}
