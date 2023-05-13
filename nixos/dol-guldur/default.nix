{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./homelab.nix
    ./networking.nix
  ];

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  nix.settings.trusted-users = [ config.mySystem.user ];

  networking.hostName = "dol-guldur";

  services = {
    openssh.enable = true;
    fail2ban.enable = true;
  };

  system.stateVersion = "22.11";
}
