{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  cfg = hl.logging;
  port = 9428;
in
{
  options.homelab.logging = with lib; {
    enable = mkEnableOption "logging";
    retentionPeriod = mkOption {
      type = types.str;
      default = "30d";
    };
    port = mkOption {
      readOnly = true;
      default = port;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = hl.nebula.enable;
      message = "homelab.logging requires homelab.nebula to receive logs from other hosts";
    }];

    homelab.traefik = {
      enable = true;
      services.victorialogs = { host = hl.nebula.address; inherit port; };
    };

    services = {
      victorialogs = {
        enable = true;
        listenAddress = "${hl.nebula.address}:${toString port}";
        extraOptions = [ "-retentionPeriod=${cfg.retentionPeriod}" ];
      };
      grafana = lib.mkIf hl.monitoring.enable {
        declarativePlugins = [ pkgs.grafanaPlugins.victoriametrics-logs-datasource ];
        provision.datasources.settings.datasources = [{
          name = "VictoriaLogs";
          type = "victoriametrics-logs-datasource";
          uid = "victorialogs";
          access = "proxy";
          url = "http://${config.services.victorialogs.listenAddress}";
          editable = false;
        }];
      };
      nebula.networks.homelab.firewall.inbound = [
        { inherit port; proto = "tcp"; host = "any"; }
      ];
    };

    # Bind to the nebula address, which only exists once the tunnel is up
    systemd.services.victorialogs = {
      after = [ "nebula@homelab.service" ];
      wants = [ "nebula@homelab.service" ];
    };

    networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [ port ];
  };
}
