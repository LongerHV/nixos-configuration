{ config, pkgs, ... }:
let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers.minio_router = util.traefik_router { subdomain = "minio"; middlewares = [ "authelia" ]; };
    services.minio_service = util.traefik_service { port = 9001; };
  };

  age.secrets = {
    minio_credentials = {
      file = ../../../secrets/nasgul_minio_root_credentials.age;
      owner = "minio";
    };
  };

  services.minio = {
    enable = true;
    region = "eu-central-1";
    dataDir = [ "/chonk/minio" ];
    rootCredentialsFile = config.age.secrets.minio_credentials.path;
  };
}
