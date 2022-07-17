{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ./selfhosted ./snapshots.nix ];
  myDomain = "longerhv.xyz";

  boot.loader.grub = {
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
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;

  nix.settings = {
    substituters = [
      "http://mordor.lan:5000"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "mordor.lan:fY4rXQ7QqtaxsokDAA57U0kuXvlo9pzn3XgLs79TZX4"
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  networking = {
    hostName = "nasgul";
    hostId = "48392063";
    useDHCP = false;
    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    nat = {
      enable = true;
      externalInterface = "eth0";
    };
    iproute2.enable = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = [
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  age.secrets = {
    cache_priv_key.file = ../../secrets/nasgul_cache_priv_key.pem.age;
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.cache_priv_key.path;
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
  };

  system.stateVersion = "21.05";
}

