{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.netdata_router = util.traefik_router { subdomain = "netdata"; };
    services.netdata_service = util.traefik_service { port = 19999; };
  };

  services.netdata = {
    enable = true;
    config.global = {
      "update every" = "15";
    };
  };
}
