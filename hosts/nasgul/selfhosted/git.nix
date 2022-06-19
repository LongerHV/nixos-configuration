{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.gitea_router = util.traefik_router { subdomain = "gitea"; };
    services.gitea_service = util.traefik_service { port = 3000; };
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
