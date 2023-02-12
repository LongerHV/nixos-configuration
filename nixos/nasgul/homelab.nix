{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
in
{
  services.gitea.package = pkgs.unstable.gitea;
  homelab = {
    domain = "longerhv.xyz";
    storage = "/chonk";
    authelia = { enable = true; };
    traefik = {
      enable = true;
      docker.enable = true;
      cloudflareTLS = {
        enable = true;
        apiEmailFile = secrets.cloudflare_email.path;
        dnsApiTokenFile = secrets.cloudflare_token.path;
      };
      services.traefik = { port = 8080; authelia = true; };
      services.cache = { port = 5000; };
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
    mysql = {
      enable = true;
      package = pkgs.mariadb_108;
    };
    gitea.enable = true;
    multimedia = {
      enable = true;
      jellyfin.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
      bazarr.enable = true;
      deluge = {
        enable = true;
        interface = "wg1";
      };
    };
  };
}
