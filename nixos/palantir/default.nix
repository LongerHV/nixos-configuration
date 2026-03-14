{ inputs, config, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  mySystem = {
    gnome.enable = true;
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
    zfs.forceImportRoot = false;
  };

  networking = {
    hostName = "palantir";
    hostId = "656ad412"; # required by ZFS
    networkmanager.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = config.mySystem.user;
  };

  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  system.stateVersion = "25.11";
}
