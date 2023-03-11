{ pkgs, ... }:

{
  homelab = {
    domain = "dol-guldur.longerhv.xyz";
    storage = "/data";
    # traefik.enable = true;
    # gitea.enable = true;
    mysql = {
      enable = true;
      package = pkgs.mariadb_108;
    };
  };
}
