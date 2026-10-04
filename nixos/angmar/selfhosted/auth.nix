{ config, lib, pkgs, outputs, ... }:

let
  inherit (config.age) secrets;
  inherit (config.homelab) domain;
  authelia = config.services.authelia.instances.main;
  redis = config.services.redis.servers."";
  port = 9092;
  storagePath = "/var/lib/authelia-main/db.sqlite3";
  autheliaSecret = file: {
    file = ../../../secrets/${file}.age;
    owner = authelia.user;
  };
in
{
  environment.systemPackages = [ authelia.package ];

  users.users."${authelia.user}".extraGroups = [ "redis" "sendgrid" ];

  age.secrets = {
    authelia_jwt_secret = autheliaSecret "authelia_jwt_secret";
    authelia_storage_encryption_key = autheliaSecret "authelia_storage_encryption_key";
    authelia_session_secret = autheliaSecret "authelia_session_secret";
    authelia_hmac_secret = autheliaSecret "authelia_hmac_secret";
    authelia_issuer_priv_key = autheliaSecret "authelia_issuer_private_key";
    ldap_password = autheliaSecret "ldap_password";
  };

  homelab = {
    auth.autheliaUrl = "http://127.0.0.1:${toString port}";
    traefik.services.auth = { inherit port; };
    backups.services.auth = {
      backupPrepareCommand = ''
        ${pkgs.sqlite}/bin/sqlite3 ${storagePath} ".backup /tmp/authelia.sqlite3"
      '';
      backupCleanupCommand = "rm -f /tmp/authelia.sqlite3";
      paths = [ "/tmp/authelia.sqlite3" ];
    };
  };

  # nasgul's Traefik asks Authelia for forward auth over nebula.
  services.nebula.networks.homelab.firewall.inbound = [{ proto = "tcp"; inherit port; host = "nasgul"; }];
  networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [ port ];

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = secrets.authelia_jwt_secret.path;
      oidcHmacSecretFile = secrets.authelia_hmac_secret.path;
      oidcIssuerPrivateKeyFile = secrets.authelia_issuer_priv_key.path;
      sessionSecretFile = secrets.authelia_session_secret.path;
      storageEncryptionKeyFile = secrets.authelia_storage_encryption_key.path;
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = secrets.ldap_password.path;
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.homelab.mail.smtp.passFile;
    };
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      # All interfaces: local Traefik plus nasgul over nebula; the firewall only
      # opens the port on the nebula interface.
      server.address = "tcp://0.0.0.0:${toString port}";
      log.level = "info";
      totp.issuer = "authelia.com";
      session = {
        cookies = [{
          inherit domain;
          authelia_url = "https://auth.${domain}";
          default_redirection_url = "https://homepage.${domain}";
        }];
        redis = {
          host = redis.unixSocket;
          port = 0;
          database_index = 0;
        };
      };
      regulation = {
        max_retries = 3;
        find_time = 120;
        ban_time = 300;
      };
      authentication_backend = {
        password_reset.disable = false;
        refresh_interval = "1m";
        ldap = {
          implementation = "custom";
          address = "ldap://localhost:3890";
          timeout = "5m";
          start_tls = false;
          base_dn = "dc=longerhv,dc=xyz";
          additional_users_dn = "ou=people";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=groups";
          groups_filter = "(member={dn})";
          user = "uid=admin,ou=people,dc=longerhv,dc=xyz";
          attributes = {
            display_name = "displayName";
            group_name = "cn";
            mail = "mail";
            username = "uid";
          };
        };
      };
      access_control = {
        default_policy = "deny";
        networks = [
          {
            name = "localhost";
            networks = [ "127.0.0.1/32" ];
          }
          {
            name = "internal";
            networks = [
              "10.100.0.0/8"
              "172.16.0.0/12"
              "192.168.0.0/16"
              "fda9:4a50:e34b::/48"
            ];
          }
        ];
        rules = [
          {
            domain = "*.${domain}";
            policy = "bypass";
            networks = "localhost";
          }
          {
            domain = "*.${domain}";
            policy = "one_factor";
            networks = "internal";
            subject = [
              "group:admin"
            ];
          }
        ];
      };
      storage.local.path = storagePath;
      notifier = {
        disable_startup_check = true;
        smtp =
          let
            inherit (config.homelab.mail) smtp;
          in
          {
            address = "submissions://${smtp.host}:${toString smtp.port}";
            username = smtp.user;
            sender = "authelia@longerhv.xyz";
          };
      };
      # Clients declared on this host plus those of services running on nasgul.
      identity_providers.oidc = lib.mkMerge [
        config.homelab.auth.oidc
        outputs.nixosConfigurations.nasgul.config.homelab.auth.oidc
      ];
    };
  };

  systemd.services.authelia-main = {
    after = [ "lldap.service" "redis.service" ];
    wants = [ "lldap.service" ];
  };
}
