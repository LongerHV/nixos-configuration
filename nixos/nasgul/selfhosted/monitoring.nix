{ config, pkgs, ... }:

{
  homelab.traefik.services.netdata = {
    port = 19999;
    authelia = true;
  };

  services = {
    netdata = {
      enable = true;
      config.global = {
        "update every" = "15";
      };
    };
  };
}
