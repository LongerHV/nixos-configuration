{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
in
{
  services = {
    mysql.package = pkgs.mariadb_106;
  };

  homelab = {
    domain = "longerhv.xyz";
    storage = "/chonk";
    traefik = {
      enable = true;
      services.traefik.port = 8080;
      services.cache.port = 5000;
      docker.enable = true;
      cloudflareTLS = {
        enable = true;
        apiEmailFile = secrets.cloudflare_email.path;
        dnsApiTokenFile = secrets.cloudflare_token.path;
      };
    };
    mail = {
      enable = true;
      smtp = {
        host = "smtp.sendgrid.net";
        port = 465;
        user = "apikey";
        passFile = secrets.sendgrid_token.path;
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
