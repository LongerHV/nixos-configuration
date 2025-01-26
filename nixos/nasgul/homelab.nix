{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
  hl = config.homelab;
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
      package = pkgs.mariadb_1011;
    };
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      adminpassFile = secrets.nextcloud_admin_password.path;
      tmpdir = "/var/tmp";
    };
    gitea = {
      enable = true;
      actions = {
        enable = true;
        tokenFile = secrets.gitea_actions_token.path;
      };
    };
    multimedia = {
      enable = true;
      deluge.interface = "wg1";
    };
  };

  systemd.services.gitea-runner-nasgul.serviceConfig.SupplementaryGroups = [ "gitea-secrets" ];
  services.gitea-actions-runner.package = pkgs.unstable.gitea-actions-runner;

  services = {
    postgresql.package = pkgs.postgresql_14;
    prowlarr.package = pkgs.unstable.prowlarr;
    gitea = {
      package = pkgs.unstable.gitea;
      settings.packages.CHUNKED_UPLOAD_PATH = "${config.services.gitea.stateDir}/tmp/package-upload";
    };
    nextcloud.maxUploadSize = "32G";
    traefik.dynamicConfigOptions.http = {
      middlewares = {
        notes-add-prefix.addPrefix.prefix = "/notes";
        notes-add-index.replacepathregex = {
          regex = "(.*)/$";
          replacement = "$1/index.html";
        };
      };
    };
  };
}
