{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
  };
  homelab.nebula.enable = true;

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };


  networking = {
    hostName = "isildur";
    wireless.enable = false;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      dispatcherScripts = [
        {
          # Permanent neighbor entry for anarion (OTBR TREL peer on AP downstairs).
          # Bypasses the Linux 6.6.x bridge MLD querier bug: the bridge querier never
          # sends MLD queries (IPv6 address not valid at startup, never retried), so MDB
          # entries expire and multicast-to-unicast stops working. With a permanent neigh
          # entry, NDP is not needed at all for this peer — the kernel resolves the MAC
          # directly without sending any Neighbor Solicitation.
          source = pkgs.writeShellScript "otbr-neighbors" ''
            [ "$1" = "wlan0" ] && [ "$2" = "up" ] || exit 0
            ip -6 neigh replace fe80::fc3a:e35f:472f:63bd \
              lladdr 88:a2:9e:8c:c8:0c dev wlan0 nud permanent
          '';
          type = "basic";
        }
      ];
    };
  };

  services.openssh.enable = true;

  services.otbr = {
    enable = true;
    rcpDevice = "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device_DA241A36F28D-if00";
    infraInterface = "wlan0";
  };

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-users = [ config.mySystem.user ];
  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.11";
}
