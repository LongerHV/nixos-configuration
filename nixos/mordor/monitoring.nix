{ config, ... }:

let
  address = "10.42.0.2";
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    ;
in
{
  services = {
    prometheus.exporters.node = {
      enable = true;
      listenAddress = address;
      enabledCollectors = [ "systemd" ];
      disabledCollectors = [ "btrfs" "mdadm" "selinux" "xfs" ];
    };
    prometheus.exporters.smartctl = {
      enable = true;
      listenAddress = address;
    };
    nebula.networks.homelab.firewall = {
      inbound = [
        { proto = "tcp"; port = toString node.port; group = "prometheus"; }
        { proto = "tcp"; port = toString smartctl.port; group = "prometheus"; }
      ];
    };
  };
  networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [
    node.port
    smartctl.port
  ];
}
