{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  users.users."${config.mainUser}".extraGroups = [ "gitea" ];

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
    repositoryRoot = "/chonk/repositories";
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
    };
  };
}
