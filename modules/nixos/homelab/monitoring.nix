{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  cfg = hl.monitoring;
  inherit (config.services) prometheus grafana;
  inherit (prometheus) exporters;
in
{
  options.homelab.monitoring = with lib; {
    enable = mkEnableOption "monitoring";
  };

  config = lib.mkIf cfg.enable {
    homelab = {
      traefik = {
        enable = true;
        services.grafana = { port = grafana.settings.server.http_port; };
        services.prometheus = { inherit (prometheus) port; };
        metrics.node-exporter = { inherit (exporters.node) port; };
        metrics.smartctl-exporter = { inherit (exporters.smartctl) port; };
      };
    };
    services = {
      grafana = {
        enable = true;
        declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
        settings = {
          server = {
            domain = "grafana.${hl.domain}";
            http_port = 3001;
          };
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
            check_for_plugin_updates = false;
          };
          security.disable_gravatar = true;
          panels.disable_sanitize_html = true;
        };
        provision = {
          datasources.settings.datasources = [{
            name = "Prometheus";
            type = "prometheus";
            uid = "PBFA97CFB590B2093";
            access = "proxy";
            url = "http://localhost:${builtins.toString prometheus.port}";
            isDefault = true;
            version = 1;
            editable = false;
          }];
          dashboards.settings.providers = [{
            name = "system";
            options.path = ./dashboards/node.json;
          }];
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
            job_name = config.networking.hostName;
            static_configs = [
              {
                targets = [
                  "node-exporter.${hl.domain}"
                  "smartctl-exporter.${hl.domain}"
                ];
              }
            ];
          }
        ];
      };
    };
    networking.hosts."127.0.0.1" = map (subdomain: "${subdomain}.${config.myDomain}") [
      "node-exporter"
      "smartctl-exporter"
      "traefik-metrics"
    ];
  };
}
