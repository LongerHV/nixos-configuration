{ config, pkgs, ... }:

{
  imports = [
    ../hosts-common.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "testvm";

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  programs.neovim = { enable = true; defaultEditor = true; };
  programs.git = { enable = true; };

  services.openssh.enable = true;
  system.stateVersion = "21.11";
}
