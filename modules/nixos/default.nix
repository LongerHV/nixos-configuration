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
  authelia = import ./authelia.nix;
  dashy = import ./dashy.nix;
  gaming = import ./gaming.nix;
  gnome = import ./gnome.nix;
  system = import ./system.nix;
  user = import ./user.nix;
  homelab = import ./homelab;
}
