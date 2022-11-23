{ config, pkgs, ... }:

{
  services = {
    mysql.package = pkgs.mariadb_106;
  };

  homelab = {
    domain = "longerhv.xyz";
    storage = "/chonk";
    mail = {
      enable = true;
      smtp = {
        host = "smtp.sendgrid.net";
        port = 465;
        user = "apikey";
        passFile = config.age.secrets.sendgrid_token.path;
      };
    };
    redis = {
      enable = true;
      databases = 3;
      # Databases:
      # 0: Authelia
      # 1: Gitea
      # 2: Blocky
    };
    mysql.enable = true;
    gitea.enable = true;
  };
}
