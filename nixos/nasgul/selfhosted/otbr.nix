{ config, pkgs, ... }:

{
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
    extraOptions = [
      "--network=host"
    ];
    capabilities = {
      NET_ADMIN = true;
    };
    devices = [
      "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device_E212FEDD5954-if00:/dev/ttyACM0"
      "/dev/net/tun:/dev/net/tun"
    ];
    volumes = [
      "${config.homelab.storage}/otbr:/data"
    ];
    environment = {
      OT_INFRA_IF = "vlan20";
      OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/ttyACM0";
      OT_THREAD_IF = "wpan0";
      NAT64 = "0";
      FIREWALL = "0";
    };
  };
}
