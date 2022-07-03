{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
  redis = config.services.redis.servers."";
  inherit (config.services) gitea;
in
{
  imports = [ ./database.nix ./redis.nix ];
  users.users."${config.mainUser}".extraGroups = [ "gitea" ];
  users.users."${gitea.user}".extraGroups = [ "redis" ];

  services.traefik.dynamicConfigOptions.http = {
    routers.gitea_router = util.traefik_router { subdomain = "gitea"; };
    services.gitea_service = util.traefik_service { port = 3000; };
  };

  services.mysql = {
    ensureDatabases = [ "gitea" ];
    ensureUsers = [
      {
        name = config.services.gitea.database.user;
        ensurePermissions = {
          "gitea.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.gitea = {
    enable = true;
    rootUrl = "https://gitea.local.${config.myDomain}";
    repositoryRoot = "/chonk/repositories";
    # disableRegistration = true;
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
    };
    settings = {
      session = {
        PROVIDER = "db";
        PROVIDER_CONFIG = "";
      };
      cache = {
        ENABLED = true;
        ADAPTER = "redis";
        HOST = "network=unix,addr=${redis.unixSocket},db=1,pool_rize=100,idle_timeout=180";
      };
    };
  };
}
