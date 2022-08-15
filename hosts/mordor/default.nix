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
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.tmpOnTmpfs = true;
  zramSwap.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  hardware.bluetooth.enable = true;

  # FIXME: For some reason cpu will not go above 4GHz...
  powerManagement = {
    cpuFreqGovernor = "ondemand";
    cpufreq.min = 800000;
    cpufreq.max = 4700000;
  };

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

  age.secrets = {
    cache_priv_key.file = ../../secrets/mordor_cache_priv_key.pem.age;
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
  };
  system.stateVersion = "22.05";
}
