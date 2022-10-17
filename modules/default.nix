{ lib, pkgs, ... }:

{
  imports = [
    ./authelia.nix
    ./dashy.nix
  ];
  options.mainUser = lib.mkOption {
    default = "longer";
    type = lib.types.str;
  };
  options.myDomain = lib.mkOption {
    type = lib.types.str;
  };
}
