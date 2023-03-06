{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.blocky;
  redis = config.services.redis.servers."";
  domain = "blocky.local.${hl.domain}";
in
{
  options.homelab.blocky = with lib; {
    enable = mkEnableOption "blocky";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      homelab = {
        redis.enable = true;
        traefik.services.blocky = { port = 4000; authelia = true; };
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
          # Cloudflare upstream DNS servers
          upstream.default = [ "1.1.1.1" "1.0.0.1" ];
          bootstrapDns = "tcp+udp:1.1.1.1";
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
      services.prometheus.scrapeConfigs = [{
        job_name = "blocky";
        static_configs = [{ targets = [ domain ]; }];
      }];
      services.blocky.settings.prometheus.enable = true;
      services.grafana.provision.dashboards.settings.providers = [{
        name = "blocky";
        options.path = ./dashboards/blocky.json;
      }];
      services.traefik.dynamicConfigOptions.http.routers.blocky-monitoring = {
        rule = "Host(`${domain}`) && Path(`/metrics`)";
        service = "blocky";
        middlewares = [ "localhost-only" ];
        entrypoints = [ hl.traefik.entrypoint ];
      };
      networking.hosts."127.0.0.1" = [ domain ];
    })
  ]);
}
