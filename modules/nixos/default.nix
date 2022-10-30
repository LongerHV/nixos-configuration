{
  default = { lib, ... }: {
    options = {
      myDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  authelia = import ./authelia.nix;
  dashy = import ./dashy.nix;
  system = import ./system.nix;
  user = import ./user.nix;
}
