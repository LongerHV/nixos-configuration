# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/root/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/root/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "rpool/root/var";
      fsType = "zfs";
    };

  fileSystems."/chonk" =
    { device = "rpool/root/chonk";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/EC83-EFDC";
      fsType = "vfat";
    };

  fileSystems."/boot-fallback" =
    { device = "/dev/disk/by-uuid/EC84-4BF0";
      fsType = "vfat";
    };

  swapDevices = [ ];

}
