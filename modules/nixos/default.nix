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
  mySystem = import ./mySystem;
  homelab = import ./homelab;

  authelia = import ./authelia.nix;
  dashy = import ./dashy.nix;
}
