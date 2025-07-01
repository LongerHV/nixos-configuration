{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ./networking.nix
    ./vm-variant.nix
    ./ai.nix
  ];

  mySystem = {
    gnome.enable = true;
    gaming.enable = true;
    embedded.enable = true;
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
    supportedFilesystems = [ "zfs" "ntfs" ];
    zfs = {
      forceImportRoot = false;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd.luks = {
      fido2Support = true;
      devices.cryptroot = {
        device = "/dev/disk/by-uuid/9155264d-cd48-4d15-bb74-00a9351053d9";
        allowDiscards = true;
        preOpenCommands = ''
          read -rsp "Yubikey PIN: " YUBIKEY_PIN
          echo -n "''$YUBIKEY_PIN" > /crypt-ramfs/yubikey-pin
        '';
        postOpenCommands = ''
          rm -f /crypt/ramfs/yubikey-pin
        '';
        fido2 = {
          passwordLess = true;
          gracePeriod = 60;
          credentials = [
            # Generate and add credentials to the LUKS device:
            # fido2luks credential --pin
            # sudo fido2luks add-key /dev/nvme0n1p2 <credentials-id> -P --salt "string:"
            "9c024837f97e2dd71cbf9c22f00c967426fbb467391e5584d84e524c202a27fae5573e145cc68e353f6e86139fb5b43c" # Yubi
            "78e68b8392dc93d9ad7a4584718633f9f57a09d6b4d2c6b47504687a343c93beb5ec375588464c78c461a246726ec275" # Yubi-backup
            "\" \"--pin\" \"--pin-source\" \"/crypt-ramfs/yubikey-pin" # Ugly hack to inject additional arguments to fido2luks
          ];
        };
      };
    };
  };
  services = {
    zfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
    sanoid = {
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



    # Enable openssh only to provide key for agenix
    openssh = {
      enable = true;
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
      nssmdns4 = true;
    };
    udev.packages = with pkgs; [ qmk-udev-rules yubikey-personalization via ];
    pcscd.enable = true;

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
    yubioath-flutter
  ];
  users.users.${config.mySystem.user}.extraGroups = [ "dialout" ];
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
  ];

  age.secrets = {
    cache_priv_key.file = ../../secrets/mordor_cache_priv_key.pem.age;
    extra_access_tokens = {
      file = ../../secrets/extra_access_tokens.age;
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
  system.stateVersion = "22.05";
}
