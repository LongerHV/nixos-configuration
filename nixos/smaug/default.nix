{ config, pkgs, lib, ... }:

{
  # This configuration worked on 09-03-2021 nixos-unstable @ commit 102eb68ceec
  # The image used https://hydra.nixos.org/build/134720986

  boot = {
    # kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # A lot GUI programs need this, nearly all wayland applications
      "cma=128M"
    ];
  };

  boot.loader.raspberryPi = {
    uboot.enable = true;
    version = 4;
  };
  boot.loader.grub.enable = false;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "smaug";
    networkmanager = {
      enable = true;
    };
  };
  services.openssh.enable = true;

  nix = {
    settings.auto-optimise-store = true;
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  system.stateVersion = "22.11";
}
