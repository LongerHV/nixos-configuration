{ config, ... }:

{
  users.groups.sendgrid = { }; # Access to SMTP password file

  age.secrets = {
    # Nix-serve
    cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;

    # Nix (gitnub token)
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
    };
    restic_password = {
      file = ../../secrets/nasgul_restic_password.age;
    };
  };
}
