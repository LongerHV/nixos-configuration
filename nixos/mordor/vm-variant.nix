{ config, lib, ... }:

{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };
    users.users.${config.mySystem.user}.hashedPassword = "$y$j9T$eqAujvURywlDsQKPXzPjo.$VydW81f92LoGsVB5I5d1X0Ez6dHKEVHLTvMf4NXzbv/";
    services.xserver.displayManager = {
      gdm.autoSuspend = false;
      autoLogin = {
        enable = true;
        inherit (config.mySystem) user;
      };
    };
    networking.wg-quick.interfaces = lib.mkForce { };
    services.nix-serve.enable = lib.mkForce false;
    services.resolved.extraConfig = lib.mkForce "";
    virtualisation.docker.storageDriver = lib.mkForce "overlay2";
  };
}
