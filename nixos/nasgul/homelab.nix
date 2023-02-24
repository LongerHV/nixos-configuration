{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
in
{
  homelab = {
    domain = "longerhv.xyz";
    storage = "/chonk";
    backups = {
      enable = true;
      bucket = "s3:s3.us-east-005.backblazeb2.com/nasgulbackup";
      passwordFile = secrets.restic_password.path;
      environmentFile = secrets.restic_credentials.path;
    };
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
      databases = 4;
      # Databases:
      # 0: Authelia
      # 1: Gitea
      # 2: Blocky
      # 3: Nextcloud
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

  services = {
    gitea.package = pkgs.unstable.gitea;
    jellyfin.package = pkgs.unstable.jellyfin;
  };
}
