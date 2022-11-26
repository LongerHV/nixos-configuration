{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  users.groups.multimedia = { };
  users.users."${config.mySystem.user}".extraGroups = [ "multimedia" ];

  services = {
    traefik.dynamicConfigOptions.http = {
      routers = {
        sonarr_router = util.traefik_router { subdomain = "sonarr"; middlewares = [ "authelia" ]; };
        bazarr_router = util.traefik_router { subdomain = "bazarr"; middlewares = [ "authelia" ]; };
        radarr_router = util.traefik_router { subdomain = "radarr"; middlewares = [ "authelia" ]; };
        prowlarr_router = util.traefik_router { subdomain = "prowlarr"; middlewares = [ "authelia" ]; };
        deluge_router = util.traefik_router { subdomain = "deluge"; middlewares = [ "authelia" ]; };
        jellyfin_router = util.traefik_router { subdomain = "jellyfin"; };
      };
      services = {
        sonarr_service = util.traefik_service { port = 8989; };
        bazarr_service = util.traefik_service { port = 6767; };
        radarr_service = util.traefik_service { port = 7878; };
        prowlarr_service = util.traefik_service { port = 9696; };
        deluge_service = util.traefik_service { port = 8112; };
        jellyfin_service = util.traefik_service { port = 8096; };
      };
    };
    jellyfin = {
      enable = true;
      package = pkgs.unstable.jellyfin;
      group = "multimedia";
    };
    sonarr = { enable = true; group = "multimedia"; };
    radarr = { enable = true; group = "multimedia"; };
    bazarr = { enable = true; group = "multimedia"; };
    prowlarr = { enable = true; };
    deluge = {
      enable = true;
      group = "multimedia";
      web.enable = true;
      dataDir = "/chonk/media/torrent";
      declarative = true;
      config = {
        outgoing_interface = "wg1";
        enabled_plugins = [ "Label" ];
      };
      authFile = pkgs.writeTextFile {
        name = "deluge-auth";
        text = ''
          localclient::10
        '';
      };
    };
  };
}
