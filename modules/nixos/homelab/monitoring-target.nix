{ config, lib, ... }:

let
  cfg = config.homelab.monitoringTarget;
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    ;
  listenAddress = config.homelab.nebula.address;
in
{
  options.homelab.monitoringTarget = with lib; {
    enable = mkEnableOption "monitoringTarget";
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus.exporters.node = {
        enable = true;
        inherit listenAddress;
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "btrfs" "mdadm" "selinux" "xfs" ];
      };
      prometheus.exporters.smartctl = {
        enable = true;
        inherit listenAddress;
      };
      nebula.networks.homelab.firewall = {
        inbound = map
          (exporter: { proto = "tcp"; inherit (exporter) port; group = "prometheus"; }) [
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
