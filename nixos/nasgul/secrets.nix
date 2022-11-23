{ config, ... }:

{
  users.groups.sendgrid = { }; # Access to SMTP password file
  age.secrets = {
    cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;
    extra_access_tokens = {
      file = ../../secrets/extra_access_tokens.age;
      mode = "0440";
      group = config.users.groups.keys.name;
    };
    sendgrid_token = {
      file = ../../secrets/nasgul_sendgrid_token.age;
      mode = "0440";
      group = "sendgrid";
    };
  };
}
