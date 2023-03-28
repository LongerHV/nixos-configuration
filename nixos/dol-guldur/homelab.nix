{ pkgs, ... }:

{
  homelab = {
    domain = "dol-guldur.longerhv.xyz";
    storage = "/data";
    traefik.enable = true;
    traefik.defaultIPWhitelist = "";
    gitea.enable = true;
    monitoring.enable = true;
    mysql = {
      enable = true;
      package = pkgs.mariadb_108;
    };
  };
}
