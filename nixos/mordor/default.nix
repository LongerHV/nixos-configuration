{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ./networking.nix
    ./vm-variant.nix
  ];

  mySystem = {
    gnome.enable = true;
    gaming.enable = true;
    vmHost = true;
    dockerHost = true;
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        zfsSupport = true;
      };
    };
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      devNodes = "/dev/disk/by-partuuid";
    };
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  services.sanoid = {
    enable = true;
    interval = "daily";
    templates.default = {
      hourly = 0;
      daily = 14;
      monthly = 3;
      yearly = 0;
    };
    datasets = {
      "rpool/root" = {
        useTemplate = [ "default" ];
      };
      "rpool/root/home" = {
        useTemplate = [ "default" ];
      };
      "rpool/root/var" = {
        useTemplate = [ "default" ];
      };
    };
  };
  hardware.bluetooth.enable = true;

  powerManagement = {
    cpuFreqGovernor = "ondemand";
    cpufreq.min = 800000;
    cpufreq.max = 4700000;
  };

  networking = {
    hostName = "mordor";
    hostId = "0c55ff12";
  };

  virtualisation.docker.storageDriver = "zfs";
  environment.systemPackages = with pkgs; [
    deploy-rs
    unstable.yubioath-flutter
  ];
  users.users.${config.mySystem.user}.extraGroups = [ "dialout" ];
  hardware.opengl = {
    enable = true;
    extraPackages = [
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  age.secrets = {
    cache_priv_key.file = ../../secrets/mordor_cache_priv_key.pem.age;
    extra_access_tokens = {
      file = ../../secrets/extra_access_tokens.age;
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };

  services = {
    # Enable openssh only to provide key for agenix
    openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = false;
    };
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = config.age.secrets.cache_priv_key.path;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        xerox-generic-driver
      ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
    udev.packages = with pkgs; [ qmk-udev-rules yubikey-personalization ];
    pcscd.enable = true;
  };
  system.stateVersion = "22.05";
}
