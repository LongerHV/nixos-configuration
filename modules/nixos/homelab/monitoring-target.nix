{ config, lib, ... }:

let
  cfg = config.homelab.monitoringTarget;
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    ;
in
{
  options.homelab.monitoringTarget = with lib; {
    enable = mkEnableOption "monitoringTarget";
    address = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus.exporters.node = {
        enable = true;
        listenAddress = cfg.address;
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "btrfs" "mdadm" "selinux" "xfs" ];
      };
      prometheus.exporters.smartctl = {
        enable = true;
        listenAddress = cfg.address;
      };
      nebula.networks.homelab.firewall = {
        inbound = map
          (exporter: { proto = "tcp"; port = exporter.port; group = "prometheus"; }) [
          node
          smartctl
        ];
      };
    };
    networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [
      node.port
      smartctl.port
    ];
  };
}
