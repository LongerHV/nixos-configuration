{ lib, ... }:

{
  imports = [
    ./redis.nix
    ./mysql.nix
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
