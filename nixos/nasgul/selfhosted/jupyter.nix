{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.jupyter_router = util.traefik_router { subdomain = "jupyter"; };
    services.jupyter_service = util.traefik_service { port = 8000; };
  };

  services.jupyterhub = {
    enable = true;
  };
}
