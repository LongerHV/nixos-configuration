{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # This host is built against nixpkgs-unstable (see flake.nix), but
  # modules/nixos/mySystem/default.nix unconditionally maps every flake
  # input, including the pinned "nixpkgs", into nix.registry — conflicting
  # with nixpkgs-unstable's own nixos/modules/misc/nixpkgs-flake.nix, which
  # registers "nixpkgs" to point at itself. Force it to unstable here so
  # `nix run nixpkgs#...`/`nix shell nixpkgs#...` on this host resolve
  # against the same nixpkgs the system is actually built from.
  nix.registry.nixpkgs = lib.mkForce { flake = inputs.nixpkgs-unstable; };

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
    plasma-bigscreen.enable = true;
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
