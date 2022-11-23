{ config, ... }:

{
  age.secrets = {
    cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;
    extra_access_tokens = {
      file = ../../secrets/extra_access_tokens.age;
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
}
