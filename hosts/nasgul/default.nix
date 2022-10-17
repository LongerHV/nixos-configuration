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
    extra_access_tokens = {
      file = ../../secrets/extra_access_tokens.age;
      mode = "0440";
      group = config.users.groups.keys.name;
    };
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

  users.users.${config.mainUser}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC29blSuefpfoJoNG11Ub41KgWfKitt0E1NfQnHPPrNOmQzmQDNtU7Qpt296WVhvvl4n8CgNWNT7NR986ndazBMb02LftrFHxa8mRZUd6axFAx47GyTsZHsvwLB8dGBOMp4HjzOvmRg+xo4EK3mDn17EjnsKcoW2/oO2P9sOqLIbf9LdSq5C3198ru8sUNleEQI7kmor4swZonQACEn8Xke+EozU3qZPbEiRKJEvV7OVLLVgon4TU5CnbUvuv3Vs3PEAzfH5jkcIxQPu4eE+BhwNiM0TXqhHaByqJHmFg2zgLQswp5vLwmjSlximrIiD0Fn1iLR9FTx7Oi17N2RJpsZSMDpNL33n7Yw6hH/gESlijabzsHnnphklcFblASg2+2dgyHUQd1v2Hnd20fFR0Qtcl+En1+o7g3y0mpdL4nH6j1lC5OPxz7ToEcLvdOh2t7ovPU7NukbJ269mzua5Ny2o9MeyYo4620whor2Ou88X52E2EhjlfyyhqghrfuiS14r4dpiRcXer2rlY7RCAuea14rnRy1H+gYLu3X0o84M0E0FlB8Vj9kVBOCaeNyo4Z4XajbeAvb6H/xxBWZ22UVIZwpkBtUC4i8/BKXnpyFptzHATNDhFVkWPWcOFCyy3KtgyKXHxKqy37iQS/yNuoxb0FdupV3WN5U9OXqT5xuCdw=="
  ];

  system.stateVersion = "21.05";
}

