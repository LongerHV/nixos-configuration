{ config, ... }:

{
  age.secrets = {
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

    # Authelia
    authelia_jwt_secret = {
      file = ../../secrets/nasgul_authelia_jwt_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_storage_encryption_key = {
      file = ../../secrets/nasgul_authelia_storage_encryption_key.age;
      owner = config.services.authelia.user;
    };
    authelia_session_secret = {
      file = ../../secrets/nasgul_authelia_session_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_hmac_secret = {
      file = ../../secrets/nasgul_authelia_hmac_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_issuer_priv_key = {
      file = ../../secrets/nasgul_authelia_issuer_private_key.age;
      owner = config.services.authelia.user;
    };
    authelia_secret_config = {
      file = ../../secrets/nasgul_authelia_config.age;
      owner = config.services.authelia.user;
    };
    authelia_mysql_password = {
      file = ../../secrets/nasgul_authelia_mysql_password.age;
      owner = config.services.authelia.user;
    };
    ldap_password = {
      file = ../../secrets/nasgul_ldap_password.age;
      owner = config.services.authelia.user;
    };

    # Wireguard
    age.secrets.wireguard_priv_key.file = ../../secrets/nasgul_wireguard_priv_key.age;
    age.secrets.mullvad_priv_key.file = ../../secrets/nasgul_mullvad_priv_key.age;
  };
}
