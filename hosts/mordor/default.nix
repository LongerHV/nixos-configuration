{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    zfsSupport = true;
  };
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-partuuid";
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;

  networking.hostName = "mordor";
  networking.hostId = "0c55ff12";

  networking = {
    useDHCP = false;
    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
  };

  system.stateVersion = "22.05";
}

