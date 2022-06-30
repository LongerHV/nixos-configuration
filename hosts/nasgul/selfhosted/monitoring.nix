{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.netdata_router = util.traefik_router { subdomain = "netdata"; middlewares = [ "authelia" ]; };
    routers.prometheus_router = util.traefik_router { subdomain = "prometheus"; middlewares = [ "authelia" ]; };
    routers.grafana_router = util.traefik_router { subdomain = "grafana"; middlewares = [ "authelia" ]; };
    services.netdata_service = util.traefik_service { port = 19999; };
    services.prometheus_service = util.traefik_service { port = 9090; };
    services.grafana_service = util.traefik_service { port = 3001; };
  };

  services = {
    netdata = {
      enable = true;
      config.global = {
        "update every" = "15";
      };
    };
    prometheus = {
      enable = true;
    };
    grafana = {
      enable = true;
      port = 3001;
      domain = "grafana.${config.myDomain}";
      auth.anonymous.enable = true;
    };
  };
}
