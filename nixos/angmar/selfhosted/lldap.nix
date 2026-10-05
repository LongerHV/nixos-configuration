{ config, pkgs, ... }:

let
  inherit (config.age) secrets;
  hl = config.homelab;
  ldapPort = config.services.lldap.settings.ldap_port;
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

  # LDAP for nasgul's services (Nextcloud user_ldap).
  services.nebula.networks.homelab.firewall.inbound = [{ proto = "tcp"; port = ldapPort; host = "nasgul"; }];
  networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [ ldapPort ];

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
      # Local Authelia plus nasgul's Nextcloud over nebula; the firewall only
      # opens the port on the nebula interface.
      ldap_host = "0.0.0.0";
      http_host = "127.0.0.1";
    };
    environment = {
      LLDAP_JWT_SECRET_FILE = secrets.lldap_jwt_secret.path;
      LLDAP_LDAP_USER_PASS_FILE = secrets.lldap_user_pass.path;
    };
  };

  systemd.services.lldap.serviceConfig.SupplementaryGroups = [ "lldap-secrets" ];
}
