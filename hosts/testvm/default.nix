{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "testvm";

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  services.openssh.enable = true;

  system.stateVersion = "21.11";
}
