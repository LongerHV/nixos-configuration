{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ../cache.nix
  ];

  mySystem = {
    gnome.enable = true;
    gaming.enable = true;
  };

  home-manager.users."${config.mySystem.user}" = import ../../home-manager/mordor.nix;

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
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  hardware.bluetooth.enable = true;

  powerManagement = {
    cpuFreqGovernor = "ondemand";
    cpufreq.min = 800000;
    cpufreq.max = 4700000;
  };

  services.dnsmasq = {
    enable = true;
  };
  networking = {
    hostName = "mordor";
    hostId = "0c55ff12";
    useDHCP = false;
    enableIPv6 = false;
    nameservers = [ "10.69.1.243" ];
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
    };
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    # Ignore wireguard related traffic
    firewall = {
      logReversePathDrops = true;
      extraCommands = ''
        ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eth0";
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.podman = { enable = true; dockerCompat = true; };
  environment.systemPackages = with pkgs; [ virt-manager ];
  users.users.${config.mySystem.user}.extraGroups = [ "libvirtd" ];
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
    udev.packages = with pkgs; [ qmk-udev-rules ];
    wg-netmanager.enable = true;
  };
  system.stateVersion = "22.05";
}
