{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ./selfhosted
    ./snapshots.nix
    ./homelab.nix
    ./pg_upgrade.nix
  ];
  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "mordor" ];
  };
  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      zfsSupport = true;
      mirroredBoots = [
        {
          devices = [ "nodev" ];
          path = "/boot";
        }
        {
          devices = [ "nodev" ];
          path = "/boot-fallback";
        }
      ];
    };
    loader.efi.canTouchEfiVariables = false;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };
  nix.settings.trusted-users = [ config.mySystem.user ];

  hardware.opengl = {
    enable = true;
    extraPackages = [
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.cache_priv_key.path;
    };
    openssh.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
  };

  system.stateVersion = "21.05";
}
