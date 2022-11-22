{ pkgs, ... }:

{
  services = {
    mysql.package = pkgs.mariadb_106;
  };

  homelab = {
    domain = "longerhv.xyz";
    storage = "/chonk";
    redis = {
      enable = true;
      databases = 3;
      # Databases:
      # 0: Authelia
      # 1: Gitea
      # 2: Blocky
    };
    mysql.enable = true;
  };
}
