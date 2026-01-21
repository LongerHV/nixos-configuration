{ config, ... }:

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
