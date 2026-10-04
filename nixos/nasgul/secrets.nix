{ config, ... }:

{
  users = {
    groups = {
      gitea-secrets = { };
    };
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
        file = ../../secrets/sendgrid_token.age;
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
        file = ../../secrets/restic_s3_key.age;
        mode = "0440";
        group = "restic";
      };
      restic_password = {
        file = ../../secrets/restic_password.age;
        mode = "0440";
        group = "restic";
      };

      # Nextcloud
      nextcloud_admin_password = {
        file = ../../secrets/nextcloud_admin_password.age;
        owner = "nextcloud";
      };

      # Gitea
      gitea_actions_token = {
        file = ../../secrets/gitea_actions_token.age;
        mode = "0440";
        group = "gitea-secrets";
      };

      # Vikunja
      vikunja_environment.file = ../../secrets/vikunja_environment.age;

      # Wireguard
      wireguard_priv_key.file = ../../secrets/nasgul_wireguard_priv_key.age;
      mullvad_priv_key.file = ../../secrets/nasgul_mullvad_priv_key.age;

    };
  };
}
