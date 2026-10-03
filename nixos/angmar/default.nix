{ inputs, config, ... }:

let
  lanNetwork = {
    matchConfig.Name = "eno1";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
    # The router cannot resolve the homelab domain; blocky (below) can.
    dhcpV4Config.UseDNS = false;
    ipv6AcceptRAConfig.UseDNS = false;
  };
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
    ./homelab.nix
    ./secrets.nix
  ];

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
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
      systemd = {
        enable = true;
        network = {
          enable = true;
          networks."10-lan" = lanNetwork;
        };
      };
      luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];
      # Remote unlock fallback when TPM unsealing fails (e.g. after a firmware update):
      #   ssh -p 2222 root@angmar.lan systemd-tty-ask-password-agent
      network.ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        authorizedKeys = config.users.users.${config.mySystem.user}.openssh.authorizedKeys.keys;
      };
    };
    zfs.forceImportRoot = false;
  };

  networking = {
    hostName = "angmar";
    hostId = "783b38e3"; # required by ZFS
    useNetworkd = true;
    useDHCP = false;
    nftables.enable = true;
  };
  systemd.network = {
    enable = true;
    networks."10-lan" = lanNetwork;
    wait-online.extraArgs = [ "--interface" "eno1" ];
  };

  services = {
    # Blocky on nasgul
    resolved.settings.Resolve.DNS = "10.123.1.243";
    openssh.enable = true;
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };

  documentation.enable = false;
  system.stateVersion = "26.05";
}
