{ config, lib, pkgs, ... }:

let
  cfg = config.services.otbr;

  imageInfo = {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name openthread/border-router --image-tag latest --arch amd64
    x86_64-linux = {
      imageDigest = "sha256:4d84b9b46a5f49e01da6f8ad25bfb9e73c898b9b046d5fb89619b9ad4436bf0c";
      hash = "sha256-5tg+5tVxACtXb6z1I64q7d4pjPB2W0xanK9yB2vKfCM=";
    };
    # nix run nixpkgs#nix-prefetch-docker -- --image-name openthread/border-router --image-tag latest --arch arm64
    aarch64-linux = {
      imageDigest = "sha256:4d84b9b46a5f49e01da6f8ad25bfb9e73c898b9b046d5fb89619b9ad4436bf0c";
      hash = "sha256-I+HR0v1oiLQRm+teUKpfn5+Tb8Q7LEbHfRJd5i8MYgs=";
    };
  }.${pkgs.stdenv.hostPlatform.system} or (throw "Unsupported platform for OTBR");
in
{
  options.services.otbr = with lib; {
    enable = mkEnableOption "OpenThread Border Router";

    rcpDevice = mkOption {
      type = types.str;
      example = "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device-if00";
      description = "Path to the RCP (Radio Co-Processor) serial device.";
    };

    infraInterface = mkOption {
      type = types.str;
      example = "eth0";
      description = "Infrastructure network interface for the Thread backbone.";
    };

    storage = mkOption {
      type = types.str;
      default = "/var/lib/otbr";
      description = "Path to persistent storage for Thread network data.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable IPv6 forwarding for routing between infrastructure and Thread mesh
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

    systemd.tmpfiles.rules = [
      "d ${cfg.storage} 0755 root root - -"
    ];

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
      allowInterfaces = [ cfg.infraInterface ];
      openFirewall = true;
    };

    virtualisation.oci-containers.containers.otbr = {
      image = "openthread/border-router:latest";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "openthread/border-router";
        inherit (imageInfo) imageDigest hash;
        finalImageName = "openthread/border-router";
        finalImageTag = "latest";
      };
      extraOptions = [ "--network=host" ];
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
      devices = [
        "${cfg.rcpDevice}:/dev/ttyACM0"
        "/dev/net/tun:/dev/net/tun"
      ];
      volumes = [
        "${cfg.storage}:/data"
      ];
      environment = {
        OT_INFRA_IF = cfg.infraInterface;
        OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/ttyACM0";
        OT_THREAD_IF = "wpan0";
        NAT64 = "0";
        FIREWALL = "0";
      };
    };
  };
}
