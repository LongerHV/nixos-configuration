{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
  inherit (config.services) authelia;
  redis = config.services.redis.servers.authelia;
in
{
  imports = [ ./database.nix ];
  age.secrets = {
    authelia_jwt_secret = {
      file = ../../../secrets/nasgul_authelia_jwt_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_storage_encryption_key = {
      file = ../../../secrets/nasgul_authelia_storage_encryption_key.age;
      owner = config.services.authelia.user;
    };
    authelia_session_secret = {
      file = ../../../secrets/nasgul_authelia_session_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_hmac_secret = {
      file = ../../../secrets/nasgul_authelia_hmac_secret.age;
      owner = config.services.authelia.user;
    };
    authelia_issuer_priv_key = {
      file = ../../../secrets/nasgul_authelia_issuer_private_key.age;
      owner = config.services.authelia.user;
    };
    authelia_secret_config = {
      file = ../../../secrets/nasgul_authelia_config.age;
      owner = config.services.authelia.user;
    };
  };

  environment.systemPackages = [
    pkgs.authelia
  ];

  users.users."${config.mainUser}".extraGroups = [ "authelia" ];

  services.traefik.dynamicConfigOptions.http = {
    middlewares.authelia.forwardAuth = {
      address = "http://localhost:9092/api/verify?rd=https%3A%2F%2Fauth.local.${config.myDomain}%2F";
      trustForwardHeader = true;
      authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
      tls.insecureSkipVerify = true;
    };
    middlewares.authelia-basic.forwardAuth = {
      address = "http://localhost:9092/api/verify?auth=basic";
      trustForwardHeader = true;
      authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
    };
    routers.auth_router = util.traefik_router { subdomain = "auth"; };
    services.auth_service = util.traefik_service { port = 9092; };
  };

  services.redis.servers.authelia = {
    enable = true;
    inherit (authelia) user;
  };

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
  services.authelia = {
    enable = true;
    jwtSecretFile = config.age.secrets.authelia_jwt_secret.path;
    storageEncryptionKeyFile = config.age.secrets.authelia_storage_encryption_key.path;
    oidcHmacSecretFile = config.age.secrets.authelia_hmac_secret.path;
    oidcIssuerPrivKeyFile = config.age.secrets.authelia_issuer_priv_key.path;
    settingsFile = config.age.secrets.authelia_secret_config.path;
    sessionSecretFile = config.age.secrets.authelia_session_secret.path;
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      server = {
        host = "0.0.0.0";
        port = 9092;
      };
      log.level = "info";
      totp.issuer = "authelia.com";
      session = {
        domain = config.myDomain;
        redis = {
          host = redis.unixSocket;
          port = 0;
        };
      };
      regulation = {
        max_retries = 3;
        find_time = 120;
        ban_time = 300;
      };
      authentication_backend = {
        file = {
          path = "${config.services.authelia.dataDir}/users_database.yml";
          password = {
            algorithm = "argon2id";
            iterations = 1;
            key_length = 32;
            salt_length = 16;
            memory = 1024;
            parallelism = 8;
          };
        };
      };
      access_control = {
        default_policy = "deny";
        # networks = [
        #   {
        #     name = "internal";
        #     networks = [ "192.168.1.0/24" ];
        #   }
        # ];
        rules = [
          {
            domain = "*.local.${config.myDomain}";
            policy = "one_factor";
            # networks = [ "internal" ];
          }
        ];
      };
      storage = {
        local = {
          path = "${config.services.authelia.dataDir}/db.sqlite3";
        };
      };
      notifier = {
        disable_startup_check = false;
        filesystem = {
          filename = "${config.services.authelia.dataDir}/notification.txt";
        };
      };
    };
  };
}
