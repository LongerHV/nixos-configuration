{ config, lib, pkgs, ... }:

let
  cfg = config.services.otbr;
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
    virtualisation.oci-containers.containers.otbr = {
      image = "openthread/border-router:latest";
      # nix run nixpkgs#nix-prefetch-docker -- --image-name openthread/border-router --image-tag latest
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "openthread/border-router";
        imageDigest = "sha256:263b7874a42caeab4e86d50797ce7c703233de61292e69f8afc5543b2ffbde19";
        hash = "sha256-u4N8U3emZuUXuqKgH4N5fi0O8PSwlZ6KBUFhn3AEdIA=";
        finalImageName = "openthread/border-router";
        finalImageTag = "latest";
      };
      extraOptions = [ "--network=host" ];
      capabilities.NET_ADMIN = true;
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
