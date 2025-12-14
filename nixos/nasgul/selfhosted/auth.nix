{ config, lib, ... }:

let
  authelia = config.services.authelia.instances.main;
  redis = config.services.redis.servers."";
  port = 9092;
  autheliaUrl = "http://${authelia.settings.server.address}";
  inherit (config.homelab) domain;
in
{
  environment.systemPackages = [ config.services.authelia.instances.main.package ];

  users.users."${config.mySystem.user}".extraGroups = [ "authelia" ];
  users.users."${authelia.user}".extraGroups = [ "redis" "sendgrid" ];

  homelab.traefik.services = lib.mkMerge [
    { auth = { inherit port; }; }
    (lib.genAttrs [
      "bazarr"
      "blocky"
      "deluge"
      "grafana"
      "netdata"
      "prometheus"
      "prowlarr"
      "radarr"
      "readarr"
      "sonarr"
    ]
      (_: { middlewares = [ "authelia" ]; })
    )
  ];

  services = {
    traefik.dynamicConfigOptions.http = {
      routers.traefik.middlewares = [ "authelia" ];
      middlewares.authelia.forwardAuth = {
        address = "${autheliaUrl}/api/verify?rd=https%3A%2F%2Fauth.${domain}%2F";
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

    mysql = {
      ensureDatabases = [
        "authelia"
      ];
      ensureUsers = [
        {
          name = authelia.user;
          ensurePermissions = {
            "authelia.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.age.secrets.authelia_jwt_secret.path;
        oidcHmacSecretFile = config.age.secrets.authelia_hmac_secret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia_issuer_priv_key.path;
        sessionSecretFile = config.age.secrets.authelia_session_secret.path;
        storageEncryptionKeyFile = config.age.secrets.authelia_storage_encryption_key.path;
      };
      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets.ldap_password.path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.homelab.mail.smtp.passFile;
        AUTHELIA_STORAGE_MYSQL_PASSWORD_FILE = config.age.secrets.authelia_mysql_password.path;
      };
      settings = {
        theme = "dark";
        default_2fa_method = "totp";
        server.address = "localhost:${toString port}";
        log.level = "info";
        totp.issuer = "authelia.com";
        session = {
          cookies = [{
            inherit (config.homelab) domain;
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
        storage = {
          mysql = {
            address = "/run/mysqld/mysqld.sock";
            database = "authelia";
            username = authelia.user;
          };
        };
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
        identity_providers.oidc.clients = [
          {
            authorization_policy = "one_factor";
            client_id = "jellyfin";
            client_secret = "$pbkdf2-sha512$310000$rMliY0u1kEQ0FRHrG8xvqg$8.wKSra2uT5VFhCAv1YQHHnCSSORmWDrdAv6Uns1Ae7yu24w87SW0PmH9BKrYB1YIWoo7RJhF1NtYupQ.YRyRg";
            redirect_uris = [ "https://jellyfin.${domain}/sso/OID/r/authelia" ];
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            authorization_policy = "one_factor";
            client_id = "gitea";
            client_secret = "$pbkdf2-sha512$310000$g7mufVXry1vsC5uk7KSohw$EIt7XiOdxayh8on7OCZgiLWCmRTzLW9a8Cupnoyh/aeX2M6n7Hi/KCVW7f4xk3l8pk7RFfjTGLzbqbp6FtyDYQ";
            redirect_uris = [ "https://gitea.${domain}/user/oauth2/Authelia/callback" ];
          }
          {
            authorization_policy = "one_factor";
            client_id = "immich";
            client_secret = "$pbkdf2-sha512$310000$wPpdmhrPqd.dU.tcLTh9nQ$du11GENjjxaXf5njeqnhpVgr8O9fCISulobjRStCsYJzY6i3aaOyiloRJHKDh.CC.4n1QVqsP.ty9Lo8UH3XvA";
            redirect_uris = [ "https://immich.${domain}/auth/login" "https://immich.${domain}/user-settings" "app.immich:///oauth-callback" ];
            scopes = [ "openid" "profile" "email" ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };
    };
  };

  systemd.services.authelia.after = [ "lldap.service" ];
}
