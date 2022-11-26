{
  default = { config, lib, ... }: {
    options = {
      myDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
    config = {
      myDomain = lib.mkDefault config.homelab.domain;
    };
  };
  system = import ./system;
  homelab = import ./homelab;

  authelia = import ./authelia.nix;
  dashy = import ./dashy.nix;
}
