{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
in
{
  homelab = {
    domain = "local.longerhv.xyz";
    # Same bucket as nasgul; each service keeps its own repository in it, so
    # backup history follows a service when it moves between hosts.
    backups = {
      enable = true;
      bucket = "s3:s3.us-east-005.backblazeb2.com/nasgulbackup";
      passwordFile = secrets.restic_password.path;
      environmentFile = secrets.restic_credentials.path;
    };
    traefik = {
      enable = true;
      dashboardHost = "traefik-angmar";
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
    redis.enable = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };
}
