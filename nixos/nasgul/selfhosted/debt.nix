{ config, pkgs, ... }:

# Technical debt to refactor later xD
let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.gitea_router = util.traefik_router { subdomain = "gitea"; };
    services.gitea_service = util.traefik_service { port = 3000; };
  };
}