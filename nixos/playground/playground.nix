{ config, pkgs, lib, inputs, outputs, ... }:

{
  homelab = {
    domain = "test.lan";
    traefik = {
      enable = true;
      services.traefik = { port = 8080; authelia = true; };
    };
    multimedia = {
      enable = true;
      jellyfin.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
      bazarr.enable = true;
      deluge = {
        enable = true;
      };
    };
  };
}
