{ config, lib, ... }:

let
  cfg = config.homelab.minio;
  hl = config.homelab;
  dataDir = "${hl.storage}/minio";
in
{
  options.homelab.minio = with lib; {
    enable = mkEnableOption "minio";
    rootCredentialsFile = mkOption {
      type = types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    homelab.traefik = {
      enable = true;
      services = {
        minio.port = 9000;
        minio-console.port = 9001;
      };
    };
    services.minio = {
      enable = true;
      dataDir = [ dataDir ];
      inherit (cfg) rootCredentialsFile;
    };
  };
}
