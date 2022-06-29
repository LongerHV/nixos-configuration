{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ./selfhosted ];
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
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;

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
  };

  system.stateVersion = "21.05";
}

