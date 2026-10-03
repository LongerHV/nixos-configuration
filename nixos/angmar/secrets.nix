{
  age.secrets = {
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
  };
}
