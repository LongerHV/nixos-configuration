{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services = {
    traefik.dynamicConfigOptions.http = {
      routers.mailhog_router = util.traefik_router { subdomain = "mailhog"; middlewares = [ "authelia" ]; };
      services.mailhog_service = util.traefik_service { port = 8025; };
    };
    mailhog = {
      enable = true;
    };
  };
}
