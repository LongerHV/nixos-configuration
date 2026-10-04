{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
  hl = config.homelab;
  lldapSecret = file: {
    file = ../../../secrets/${file}.age;
    mode = "0440";
    group = "lldap-secrets";
  };
in
{
  homelab = {
    traefik.services.ldap.port = 17170;
    backups.services.lldap = {
      backupPrepareCommand = ''
        ${pkgs.sqlite}/bin/sqlite3 /var/lib/private/lldap/users.db ".backup /tmp/lldap-users.db"
      '';
      backupCleanupCommand = "rm -f /tmp/lldap-users.db";
      paths = [ "/tmp/lldap-users.db" ];
    };
  };

  users.groups.lldap-secrets = { };
  age.secrets = {
    lldap_private_key = lldapSecret "lldap_private_key";
    lldap_jwt_secret = lldapSecret "lldap_jwt_secret";
    lldap_user_pass = lldapSecret "lldap_user_pass";
  };

  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://ldap.${hl.domain}";
      ldap_base_dn = "dc=longerhv,dc=xyz";
      key_file = secrets.lldap_private_key.path;
      ldap_host = "127.0.0.1";
      http_host = "127.0.0.1";
    };
    environment = {
      LLDAP_JWT_SECRET_FILE = secrets.lldap_jwt_secret.path;
      LLDAP_LDAP_USER_PASS_FILE = secrets.lldap_user_pass.path;
    };
  };

  systemd.services.lldap.serviceConfig.SupplementaryGroups = [ "lldap-secrets" ];
}
