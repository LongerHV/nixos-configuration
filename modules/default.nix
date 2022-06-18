{ lib, ... }:

{
  imports = [
    ./authelia.nix
  ];
  options.mainUser = lib.mkOption {
    default = "longer";
    type = lib.types.str;
  };
  options.myDomain = lib.mkOption {
    type = lib.types.str;
  };
}
