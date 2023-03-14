{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./klipper.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
  };

  boot.loader = {
    grub.enable = false;
    raspberryPi = {
      uboot.enable = true;
      version = 4;
    };
  };

  networking = {
    hostName = "smaug";
    networkmanager = {
      enable = true;
    };
  };
  services.openssh.enable = true;

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-users = [ config.mySystem.user ];
  system.stateVersion = "22.11";
}
