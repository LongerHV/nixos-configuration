{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.blocky;
  redis = config.services.redis.servers."";
  domain = "blocky.${hl.domain}";
in
{
  options.homelab.blocky = with lib; {
    enable = mkEnableOption "blocky";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      homelab = {
        redis.enable = true;
        traefik.services.blocky = { port = 4000; };
      };

      networking = {
        nameservers = [ "127.0.0.1" ];
        dhcpcd.extraConfig = "nohook resolv.conf";
        firewall = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };

      services.blocky = {
        enable = true;
        settings = {
          port = lib.mkDefault 53;
          httpPort = lib.mkDefault 4000;
          connectIPVersion = "v4";
          upstream.default = [
            "https://one.one.one.one/dns-query"
            "https://dns.quad9.net/dns-query"
          ];
          bootstrapDns = [
            {
              upstream = "https://one.one.one.one/dns-query";
              ips = [ "1.1.1.1" "1.0.0.1" ];
            }
            {
              upstream = "https://dns.quad9.net/dns-query";
              ips = [ "9.9.9.9" "149.112.112.112" ];
            }
          ];
          redis = {
            address = redis.unixSocket;
            database = 2;
            required = true;
            connectionAttempts = 20;
            connectionCooldown = "6s";
          };
        };
      };

      users.users.blocky = {
        group = "blocky";
        extraGroups = [ "redis" ];
        createHome = false;
        isSystemUser = true;
      };
      users.groups.blocky = { };

      systemd.services.blocky = {
        after = [ "redis.service" ];
        requires = [ "redis.service" ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "blocky";
          Group = "blocky";
        };
      };
    }

    (lib.mkIf hl.monitoring.enable {
      services = {
        prometheus.scrapeConfigs = [{
          job_name = "blocky";
          static_configs = [{ targets = [ domain ]; }];
        }];
        blocky.settings.prometheus.enable = true;
        grafana.provision.dashboards.settings.providers = [{
          name = "blocky";
          options.path = ./dashboards/blocky.json;
        }];
      };
      homelab.traefik.metrics.blocky.service = "blocky";
      networking.hosts."127.0.0.1" = [ domain ];
    })
  ]);
}
