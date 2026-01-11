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
            root_url = "https://grafana.${hl.domain}";
            http_port = 3001;
          };
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
            check_for_plugin_updates = false;
          };
          security = {
            admin_user = "admin";
            admin_password = "$__env{GRAFANA_ADMIN_PASSWORD}";
            disable_gravatar = true;
          };
          panels.disable_sanitize_html = true;
          "auth.generic_oauth" = {
            enabled = true;
            name = "Authelia";
            client_id = "grafana";
            client_secret = "$__env{GRAFANA_OIDC_SECRET}";
            scopes = "openid profile email groups";
            auth_url = "https://auth.${hl.domain}/api/oidc/authorization";
            token_url = "https://auth.${hl.domain}/api/oidc/token";
            api_url = "https://auth.${hl.domain}/api/oidc/userinfo";
            use_pkce = true;
            groups_attribute_path = "groups";
            role_attribute_path = "contains(groups[*], 'admin') && 'Admin' || 'Viewer'";
            allow_sign_up = true;
            email_attribute_path = "email";
            name_attribute_path = "name";
            login_attribute_path = "preferred_username";
          };
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
    networking.hosts."127.0.0.1" = map (subdomain: "${subdomain}.${hl.domain}") [
      "node-exporter"
      "smartctl-exporter"
      "traefik-metrics"
    ];

    # Grafana OIDC environment
    age.secrets.grafana_environment.file = ../../../secrets/nasgul_grafana_environment.age;
    systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana_environment.path;
  };
}
