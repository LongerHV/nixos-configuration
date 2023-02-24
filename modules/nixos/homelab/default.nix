{ config, lib, ... }:

let
  cfg = config.homelab;
in
{
  imports = [
    ./authelia.nix
    ./backups.nix
    ./gitea.nix
    ./mail.nix
    ./multimedia.nix
    ./mysql.nix
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
