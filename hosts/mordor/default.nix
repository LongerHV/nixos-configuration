{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../with-gui.nix
    ../gaming.nix
    ../cache.nix
  ];

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
  boot.kernelPackages = pkgs.unstable.linuxKernel.packages.linux_zen;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;
  hardware.bluetooth.enable = true;

  services.dnsmasq = {
    enable = true;
  };
  # services.mysql = {
  #   enable = true;
  #   package = pkgs.mariadb;
  #   ensureUsers = [{ name = "longer"; ensurePermissions = { "authelia.*" = "ALL PRIVILEGES"; }; }];
  #   ensureDatabases = [ "authelia" ];
  # };
  networking = {
    hostName = "mordor";
    hostId = "0c55ff12";
    useDHCP = false;
    enableIPv6 = false;
    nameservers = [ "192.168.1.243" ];
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
    };
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.podman = { enable = true; dockerCompat = true; };
  environment.systemPackages = with pkgs; [ virt-manager ];
  users.users.${config.mainUser}.extraGroups = [ "libvirtd" ];
  hardware.opengl = {
    enable = true;
    extraPackages = [
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  system.stateVersion = "22.05";
}
