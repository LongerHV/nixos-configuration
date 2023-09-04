{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
in
{
  homelab = {
    domain = "local.longerhv.xyz";
    storage = "/chonk";
    backups = {
      enable = true;
      bucket = "s3:s3.us-east-005.backblazeb2.com/nasgulbackup";
      passwordFile = secrets.restic_password.path;
      environmentFile = secrets.restic_credentials.path;
    };
    monitoring = {
      enable = true;
    };
    authelia = { enable = true; };
    blocky.enable = true;
    traefik = {
      enable = true;
      docker.enable = true;
      cloudflareTLS = {
        enable = true;
        apiEmailFile = secrets.cloudflare_email.path;
        dnsApiTokenFile = secrets.cloudflare_token.path;
      };
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
      package = pkgs.mariadb_1010;
    };
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud26;
      adminpassFile = secrets.nextcloud_admin_password.path;
      tmpdir = "/var/tmp";
    };
    gitea.enable = true;
    multimedia = {
      enable = true;
      deluge.interface = "wg1";
    };
    invidious.enable = true;
    miniflux = {
      enable = true;
      adminCredentialsFile = secrets.miniflux_admin_credentials.path;
    };
    minio = {
      enable = true;
      rootCredentialsFile = secrets.minio_credentials.path;
    };
  };

  services = {
    gitea.package = pkgs.unstable.gitea;
    gitea.settings.packages.CHUNKED_UPLOAD_PATH = "${config.services.gitea.stateDir}/tmp/package-upload";
    nextcloud.maxUploadSize = "32G";
  };
}
