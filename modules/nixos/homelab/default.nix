{ config, lib, ... }:

let
  cfg = config.homelab;
in
{
  imports = [
    ./authelia.nix
    ./backups.nix
    ./blocky.nix
    ./gitea.nix
    ./homepage.nix
    ./invidious.nix
    ./mail.nix
    ./miniflux.nix
    ./minio.nix
    ./monitoring.nix
    ./multimedia.nix
    ./mysql.nix
    ./nextcloud.nix
    ./redis.nix
    ./traefik.nix
  ];
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
    };
    storage = lib.mkOption {
      type = lib.types.str;
      default = "/data";
    };
  };
  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.storage} - - - - -"
    ];
  };
}
