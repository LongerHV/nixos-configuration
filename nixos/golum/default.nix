{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
  ];
  home-manager.users."${config.mainUser}" = import ../../home-manager;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap.algorithm = "lz4";

  networking.hostName = "golum";

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.interfaces.ens5.useDHCP = true;
  networking.enableIPv6 = false;
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens5";
  networking.firewall = {
    allowedUDPPorts = [ ];
    allowedTCPPorts = [ ];
  };
  programs.nm-applet.enable = true;

  services.xserver = {
    enable = true;
    layout = "pl";
    displayManager.lightdm.enable = true;
    desktopManager.lxqt.enable = true;
  };
  # xdg.portal.lxqt.enable = true;

  hardware.pulseaudio.enable = false;
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };
  };
  system.stateVersion = "21.05";
}
