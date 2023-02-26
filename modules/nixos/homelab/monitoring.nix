{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.monitoring;
  inherit (config.services) prometheus grafana;
  inherit (prometheus) exporters;
in
{
  options.homelab.monitoring = with lib; {
    enable = mkEnableOption "monitoring";
    targets = mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    homelab = {
      traefik = {
        enable = true;
        services.grafana = { port = grafana.settings.server.http_port; authelia = true; };
        services.prometheus = { inherit (prometheus) port; authelia = true; };
        services.node-exporter = { inherit (exporters.node) port; metrics = true; };
        services.smartctl-exporter = { inherit (exporters.smartctl) port; metrics = true; };
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
            job_name = config.networking.hostName;
            static_configs = [
              {
                targets = [
                  "node-exporter.local.${hl.domain}"
                  "smartctl-exporter.local.${hl.domain}"
                  "traefik-metrics.local.${hl.domain}"
                ] ++ cfg.targets;
              }
            ];
          }
        ];
      };
    };
    networking.hosts."127.0.0.1" = map (subdomain: "${subdomain}.local.${config.myDomain}") [
      "node-exporter"
      "smartctl-exporter"
      "traefik-metrics"
    ];
  };
}
