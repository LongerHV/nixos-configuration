{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.monitoring;
  inherit (config.services) prometheus grafana;
in
{
  options.homelab.monitoring = with lib; {
    enable = mkEnableOption "monitoring";
  };

  config = lib.mkIf cfg.enable {
    homelab = {
      traefik = {
        enable = true;
        services.grafana = { port = grafana.settings.server.http_port; authelia = true; };
        services.prometheus = { inherit (prometheus) port; authelia = true; };
      };
    };
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            domain = "grafana.local.${hl.domain}";
            http_port = 3001;
          };
        };
      };
      prometheus = {
        enable = true;
        retentionTime = "30d";
        exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            disabledCollectors = [ "btrfs" "mdadm" "selinux" "xfs" ];
          };
          smartctl.enable = true;
        };
        scrapeConfigs = [
          {
            job_name = "nasgul";
            static_configs = [
              {
                targets = [
                  "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
                  "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
