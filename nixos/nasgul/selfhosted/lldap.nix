{ config, ... }:

let
  inherit (config.age) secrets;
  hl = config.homelab;
in
{
  homelab.traefik.services.ldap.port = 17170;

  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://ldap.${hl.domain}";
      ldap_base_dn = "dc=longerhv,dc=xyz";
      key_file = secrets.lldap_private_key.path;
    };
    environment = {
      LLDAP_JWT_SECRET_FILE = secrets.lldap_jwt_secret.path;
      LLDAP_LDAP_USER_PASS_FILE = secrets.lldap_user_pass.path;
    };
  };
}
