{ config, pkgs, lib, inputs, outputs, ... }:

{
  homelab = {
    domain = "playground.lan";
    storage = "/data";
    redis.enable = true;
    mysql.enable = true;
    mysql.package = pkgs.mariadb_106;
    gitea.enable = true;
    traefik.enable = true;
    traefik.services = {
      traefik = {
        port = 8080;
      };
    };
    multimedia.enable = true;
  };
}
