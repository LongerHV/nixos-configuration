{ config, lib, ... }:

let
  cfg = config.homelab;
in
{
  imports = [
    ./gitea.nix
    ./mail.nix
    ./mysql.nix
    ./redis.nix
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
