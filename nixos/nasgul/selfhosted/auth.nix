{ config, pkgs, lib, ... }:

let
  inherit (config.services) authelia;
  redis = config.services.redis.servers."";
  autheliaUrl = "http://${authelia.settings.server.host}:${builtins.toString authelia.settings.server.port}";
in
{
  environment.systemPackages = [
    pkgs.unstable.authelia
  ];

  users.users."${config.mySystem.user}".extraGroups = [ "authelia" ];
  users.users."${authelia.user}".extraGroups = [ "redis" "sendgrid" ];

  services.traefik.dynamicConfigOptions.http = {
    routers.traefik.middlewares = [ "authelia" ];
    middlewares.authelia.forwardAuth = {
      address = "${autheliaUrl}/api/verify?rd=https%3A%2F%2Fauth.${config.homelab.domain}%2F";
      trustForwardHeader = true;
      authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
      tls.insecureSkipVerify = true;
    };
    middlewares.authelia-basic.forwardAuth = {
      address = "${autheliaUrl}/api/verify?auth=basic";
      trustForwardHeader = true;
      authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
    };
  };

  homelab.traefik.services = lib.mkMerge [
    { auth.port = 9092; }
    (lib.genAttrs [
      "bazarr"
      "blocky"
      "deluge"
      "grafana"
      "netdata"
      "prometheus"
      "prowlarr"
      "radarr"
      "sonarr"
    ]
      (_: { middlewares = [ "authelia" ]; })
    )
  ];

  services.mysql = {
    ensureDatabases = [
      "authelia"
    ];
    ensureUsers = [
      {
        name = config.services.authelia.user;
        ensurePermissions = {
          "authelia.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.authelia.after = [ "docker-lldap.service" ];

  services.authelia = {
    enable = true;
    environment = {
      AUTHELIA_JWT_SECRET_FILE = config.age.secrets.authelia_jwt_secret.path;
      AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = config.age.secrets.authelia_storage_encryption_key.path;
      AUTHELIA_STORAGE_MYSQL_PASSWORD_FILE = config.age.secrets.authelia_mysql_password.path;
      AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE = config.age.secrets.authelia_hmac_secret.path;
      AUTHELIA_IDENTITY_PROVIDERS_OIDC_ISSUER_PRIVATE_KEY_FILE = config.age.secrets.authelia_issuer_priv_key.path;
      AUTHELIA_SESSION_SECRET_FILE = config.age.secrets.authelia_session_secret.path;
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets.ldap_password.path;
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.homelab.mail.smtp.passFile;
    };
    settingsFile = config.age.secrets.authelia_secret_config.path;
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      server = {
        host = "localhost";
        port = 9092;
      };
      log.level = "info";
      totp.issuer = "authelia.com";
      session = {
        inherit (config.homelab) domain;
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
          url = "ldap://localhost:3890";
          timeout = "5m";
          start_tls = false;
          base_dn = "dc=longerhv,dc=xyz";
          username_attribute = "uid";
          additional_users_dn = "ou=people";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=groups";
          groups_filter = "(member={dn})";
          group_name_attribute = "cn";
          mail_attribute = "mail";
          display_name_attribute = "displayName";
          user = "uid=admin,ou=people,dc=longerhv,dc=xyz";
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
            ];

          }
        ];
        rules = [
          {
            domain = "*.${config.homelab.domain}";
            policy = "bypass";
            networks = "localhost";
          }
          {
            domain = "*.${config.homelab.domain}";
            policy = "one_factor";
            networks = "internal";
            subject = [
              "group:admin"
            ];
          }
        ];
      };
      storage = {
        mysql = {
          host = "/run/mysqld/mysqld.sock";
          database = "authelia";
          username = config.services.authelia.user;
        };
      };
      notifier = {
        disable_startup_check = false;
        smtp = {
          inherit (config.homelab.mail.smtp) host port;
          username = config.homelab.mail.smtp.user;
          sender = "authelia@${config.homelab.domain}";
        };
      };
    };
  };
}
