{ config, lib, pkgs, ... }:

let
  # neighbourMAC/neighbourIP describe the *peer* OTBR, not this host.
  #
  # neighbourIP is the peer's EUI-64 link-local, derived from neighbourMAC
  # (88:a2:9e:XX:XX:XX -> fe80::8aa2:9eff:feXX:XXXX). Both hosts previously used
  # NetworkManager stable-privacy link-locals; when addr-gen-mode changed to
  # EUI-64 these pinned addresses silently went stale and the permanent neighbour
  # entries below pointed at addresses that no longer existed. If addr-gen-mode
  # ever changes again both values must be updated - verify on each host with:
  #   ip -6 addr show wlan0 scope link
  this = lib.getAttr config.networking.hostName {
    anarion = {
      rcpDevice = "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device_E212FEDD5954-if00";
      # isildur
      neighbourMAC = "88:a2:9e:8a:a2:7a";
      neighbourIP = "fe80::8aa2:9eff:fe8a:a27a";
    };
    isildur = {
      rcpDevice = "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device_DA241A36F28D-if00";
      # anarion
      neighbourMAC = "88:a2:9e:8c:c8:0c";
      neighbourIP = "fe80::8aa2:9eff:fe8c:c80c";
    };
  };
in
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
  homelab = {
    nebula.enable = true;
    monitoringTarget = {
      enable = true;
    };
  };

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    kernelParams = [
      "8250.nr_uarts=1"
      # ttyS0 (mini-UART) is always on GPIO 14/15 without firmware overlay;
      # ttyAMA0 (PL011) also works if enable_uart=1 is set in firmware config.txt
      "console=ttyS0,115200n8"
      "console=ttyAMA0,115200n8"
      "console=tty1"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  systemd.services."serial-getty@ttyS0".wantedBy = [ "getty.target" ];

  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        backend = "iwd";
      };
      dispatcherScripts = [
        {
          # Permanent neighbour entry for the peer OTBR (TREL over WiFi).
          # Bypasses the bridge multicast path entirely: with a permanent neigh entry the
          # kernel resolves the peer's MAC without ever sending a Neighbor Solicitation,
          # so it does not matter whether MLD snooping/the querier on the APs is behaving.
          # See network-changes.md Problems 4, 8 and 9 for the underlying bridge issues.
          source = pkgs.writeShellScript "otbr-neighbors" ''
            [ "$1" = "wlan0" ] && [ "$2" = "up" ] || exit 0
            ip -6 neigh replace ${this.neighbourIP} \
              lladdr ${this.neighbourMAC} dev wlan0 nud permanent
          '';
          type = "basic";
        }
      ];
    };
  };

  services.openssh.enable = true;

  services.otbr = {
    enable = true;
    inherit (this) rcpDevice;
    infraInterface = "wlan0";
  };

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-users = [ config.mySystem.user ];
  documentation.enable = false;
  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.11";
}
