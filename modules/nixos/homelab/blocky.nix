{ config, lib, pkgs, ... }:

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
          ports = {
            dns = lib.mkDefault 53;
            http = lib.mkDefault "127.0.0.1:4000";
          };
          connectIPVersion = "v4";
          upstreams.groups.default = [
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
          # redis = {
          #   address = redis.unixSocket;
          #   database = 2;
          #   required = true;
          #   connectionAttempts = 20;
          #   connectionCooldown = "6s";
          # };
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
          # Type=simple means systemd considers blocky "active" as soon as
          # the process forks, well before it has loaded its denylists and
          # is actually answering queries. Without this, services ordered
          # after network-online.target (which now also waits on blocky,
          # see below) can start and hit DNS resolution failures against
          # a blocky that hasn't bound/warmed up yet.
          ExecStartPost = "${pkgs.writeShellScript "blocky-wait-ready" ''
            for _ in $(seq 30); do
              ${lib.getExe pkgs.blocky} healthcheck && exit 0
              sleep 1
            done
            echo "blocky did not become healthy within 30s" >&2
            exit 1
          ''}";
        };
      };

      # blocky is this host's only configured DNS resolver (networking.nameservers
      # = [ "127.0.0.1" ] above), so the network isn't meaningfully "online" for
      # any other service until blocky itself is ready to answer queries.
      # asDropin layers this on top of upstream's network-online.target instead
      # of replacing it outright (NixOS doesn't merge full unit definitions).
      systemd.targets.network-online = {
        wants = [ "blocky.service" ];
        after = [ "blocky.service" ];
        overrideStrategy = "asDropin";
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
