{ config, lib, ... }:

let
  cfg = config.homelab.monitoringTarget;
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    systemd
    ;
  inherit (config.services) cadvisor;
  inherit (config.homelab) logging nebula;
  listenAddress = nebula.address;
in
{
  options.homelab.monitoringTarget = with lib; {
    enable = mkEnableOption "monitoringTarget";
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus.exporters = {
        node = {
          enable = true;
          inherit listenAddress;
          enabledCollectors = [ "systemd" ];
          disabledCollectors = [ "btrfs" "mdadm" "selinux" "xfs" ];
        };
        smartctl = {
          enable = true;
          inherit listenAddress;
        };
        systemd = {
          enable = true;
          inherit listenAddress;
        };
      };
      # Per systemd unit / docker container CPU, memory, IO and pressure
      cadvisor = {
        enable = true;
        inherit listenAddress;
        port = 9338;
        extraOptions = [
          "--docker_only=false"
          "--store_container_labels=false"
          "--housekeeping_interval=15s"
          "--enable_metrics=cpu,memory,diskIO,pressure,oom_event"
        ];
      };
      # Ship the journal to VictoriaLogs on nasgul
      journald.upload = {
        enable = true;
        settings.Upload.URL = "http://${nebula.hosts.nasgul}:${toString logging.port}/insert/journald";
      };
      nebula.networks.homelab.firewall = {
        inbound = map
          (exporter: { proto = "tcp"; inherit (exporter) port; group = "prometheus"; }) [
          node
          smartctl
          systemd
          cadvisor
        ];
      };
    };
    systemd.services.cadvisor.serviceConfig = {
      Restart = "on-failure";
      RestartSec = 10;
    };
    networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [
      node.port
      smartctl.port
      systemd.port
      cadvisor.port
    ];
  };
}
