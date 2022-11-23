{ lib, ... }:

{
  imports = [
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
    };
  };
}
