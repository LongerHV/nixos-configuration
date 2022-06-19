{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  users.groups.multimedia = { };
  users.users."${config.mainUser}".extraGroups = [ "multimedia" ];

  services = {
    traefik.dynamicConfigOptions.http = {
      routers = {
        sonarr_router = util.traefik_router { subdomain = "sonarr"; };
        bazarr_router = util.traefik_router { subdomain = "bazarr"; };
        radarr_router = util.traefik_router { subdomain = "radarr"; };
        prowlarr_router = util.traefik_router { subdomain = "prowlarr"; };
        transmission_router = util.traefik_router { subdomain = "transmission"; };
        jellyfin_router = util.traefik_router { subdomain = "jellyfin"; };
      };
      services = {
        sonarr_service = util.traefik_service { port = 8989; };
        bazarr_service = util.traefik_service { port = 6767; };
        radarr_service = util.traefik_service { port = 7878; };
        prowlarr_service = util.traefik_service { port = 9696; };
        transmission_service = util.traefik_service { port = 9091; };
        jellyfin_service = util.traefik_service { port = 8096; };
      };
    };
    jellyfin = { enable = true; group = "multimedia"; };
    sonarr = { enable = true; group = "multimedia"; };
    radarr = { enable = true; group = "multimedia"; };
    bazarr = { enable = true; group = "multimedia"; };
    prowlarr = { enable = true; };
    transmission = {
      enable = true;
      group = "multimedia";
      home = "/chonk/media/torrent";
      downloadDirPermissions = "775";
      settings = {
        umask = 2;
        rpc-authentication-required = false;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = "transmission.local.${config.myDomain}";
      };
    };
  };
}
