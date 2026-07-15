{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # plasma-bigscreen (modules/nixos/plasma-bigscreen.nix) comes from
  # nixpkgs-unstable for version reasons. Overlay pkgs.kdePackages to the
  # same unstable set on this host so everything the plasma6 desktopManager
  # module installs (kwin, plasma-workspace, plasma-integration, SDDM, ...)
  # stays version-matched with it, avoiding cross-version QML/ABI breakage.
  nixpkgs.overlays = [ (final: prev: { kdePackages = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.kdePackages; }) ];

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
    plasma-bigscreen.enable = true;
    gaming.enable = true;
  };
  homelab = {
    nebula.enable = true;
    monitoringTarget = {
      enable = true;
    };
  };

  nix.settings.trusted-users = [ config.mySystem.user ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
    zfs.forceImportRoot = false;
  };

  networking = {
    hostName = "palantir";
    hostId = "656ad412"; # required by ZFS
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    wl-clipboard
  ];

  systemd.tmpfiles.rules = [
    "d /games 0755 ${config.mySystem.user} users -"
  ];

  services = {
    openssh.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 9999 ]; # libespot

  hardware = {
    bluetooth.enable = true;
    intelgpu.vaapiDriver = "intel-media-driver";
  };
  documentation.enable = false;
  system.stateVersion = "25.11";
}
