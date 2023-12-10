{ config, ... }:

let
  inherit (config.age) secrets;
  autheliaUser = config.services.authelia.instances.main.user;
in
{
  users = {
    groups = {
      lldap-secrets = { };
      gitea-secrets = { };

      miniflux-secrets = { };
    };
  };

  # Miniflux
  systemd.services.miniflux.serviceConfig.SupplementaryGroups = [ "miniflux-secrets" ];
  services.miniflux.config = {
    OAUTH2_PROVIDER = "oidc";
    OAUTH2_USER_CREATION = "1";
    OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.${config.homelab.domain}";
    OAUTH2_CLIENT_REDIRECT_URL = "https://rss.${config.homelab.domain}/oauth2/oidc/callback";
    OAUTH2_CLIENT_ID_FILE = secrets.miniflux_client_id.path;
    OAUTH2_CLIENT_SECRET_FILE = secrets.miniflux_client_secret.path;
  };

  age = {
    secrets = {
      # Nix-serve
      cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;

      # Nix (github token)
      extra_access_tokens = {
        file = ../../secrets/extra_access_tokens.age;
        mode = "0440";
        group = config.users.groups.keys.name;
      };

      # SMTP (sendgrid)
      sendgrid_token = {
        file = ../../secrets/nasgul_sendgrid_token.age;
        mode = "0440";
        group = "sendgrid";
      };

      # Traefik
      cloudflare_email = {
        file = ../../secrets/cloudflare_email.age;
        owner = "traefik";
      };
      cloudflare_token = {
        file = ../../secrets/cloudflare_token.age;
        owner = "traefik";
      };

      # Restic
      restic_credentials = {
        file = ../../secrets/nasgul_restic_s3_key.age;
        mode = "0440";
        group = "restic";
      };
      restic_password = {
        file = ../../secrets/nasgul_restic_password.age;
        mode = "0440";
        group = "restic";
      };

      # Nextcloud
      nextcloud_admin_password = {
        file = ../../secrets/nasgul_nextcloud_admin_password.age;
        owner = "nextcloud";
      };

      # Gitea
      gitea_actions_token = {
        file = ../../secrets/nasgul_gitea_actions_token.age;
        mode = "0440";
        group = "gitea-secrets";
      };

      # Authelia
      authelia_jwt_secret = {
        file = ../../secrets/nasgul_authelia_jwt_secret.age;
        owner = autheliaUser;
      };
      authelia_storage_encryption_key = {
        file = ../../secrets/nasgul_authelia_storage_encryption_key.age;
        owner = autheliaUser;
      };
      authelia_session_secret = {
        file = ../../secrets/nasgul_authelia_session_secret.age;
        owner = autheliaUser;
      };
      authelia_hmac_secret = {
        file = ../../secrets/nasgul_authelia_hmac_secret.age;
        owner = autheliaUser;
      };
      authelia_issuer_priv_key = {
        file = ../../secrets/nasgul_authelia_issuer_private_key.age;
        owner = autheliaUser;
      };
      authelia_secret_config = {
        file = ../../secrets/nasgul_authelia_config.age;
        owner = autheliaUser;
      };
      authelia_mysql_password = {
        file = ../../secrets/nasgul_authelia_mysql_password.age;
        owner = autheliaUser;
      };
      ldap_password = {
        file = ../../secrets/nasgul_ldap_password.age;
        owner = autheliaUser;
      };

      # LLDAP
      lldap_private_key = {
        file = ../../secrets/nasgul_lldap_private_key.age;
        mode = "0440";
        group = "lldap-secrets";
      };
      lldap_jwt_secret = {
        file = ../../secrets/nasgul_lldap_jwt_secret.age;
        mode = "0440";
        group = "lldap-secrets";
      };
      lldap_user_pass = {
        file = ../../secrets/nasgul_lldap_user_pass.age;
        mode = "0440";
        group = "lldap-secrets";
      };

      # MinIO
      minio_credentials = {
        file = ../../secrets/nasgul_minio_credentials.age;
        owner = "minio";
      };

      # Wireguard
      wireguard_priv_key.file = ../../secrets/nasgul_wireguard_priv_key.age;
      mullvad_priv_key.file = ../../secrets/nasgul_mullvad_priv_key.age;

      # Miniflux
      miniflux_admin_credentials = {
        file = ../../secrets/nasgul_miniflux_admin_credentials.age;
        mode = "0440";
        group = "miniflux-secrets";
      };
      miniflux_client_id = {
        file = ../../secrets/nasgul_miniflux_client_id.age;
        mode = "0440";
        group = "miniflux-secrets";
      };
      miniflux_client_secret = {
        file = ../../secrets/nasgul_miniflux_client_secret.age;
        mode = "0440";
        group = "miniflux-secrets";
      };
    };
  };
}
