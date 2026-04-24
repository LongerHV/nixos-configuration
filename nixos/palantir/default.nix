{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
    plasma-bigscreen.enable = true;
  };
  homelab = {
    nebula.enable = true;
    monitoringTarget = {
      enable = true;
      address = "10.42.0.3";
    };
  };

  nix.settings.trusted-users = [ config.mySystem.user ];

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

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji

    brave
    jellyfin-media-player
    spotify
    vacuum-tube
  ];

  services.openssh.enable = true;

  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  system.stateVersion = "25.11";
}
