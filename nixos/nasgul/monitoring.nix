{ config, ... }:

let
  domain = "nebula.arpa";
  hosts = port: map (host: "${host}.${domain}:${port}") (builtins.attrNames config.homelab.nebula.hosts);
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    systemd
    ;
  inherit (config.services) cadvisor;
in
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{ targets = hosts (toString node.port); }];
    }
    {
      job_name = "smartctl";
      static_configs = [{ targets = hosts (toString smartctl.port); }];
    }
    {
      job_name = "systemd";
      static_configs = [{ targets = hosts (toString systemd.port); }];
    }
    {
      job_name = "cadvisor";
      static_configs = [{ targets = hosts (toString cadvisor.port); }];
      metric_relabel_configs = [
        # Keep the host root cgroup, services, scopes (incl. docker) and VMs; drop mounts, sockets, slices
        {
          source_labels = [ "id" ];
          regex = ''/|/system\.slice/(.+/)?[^/]+\.(service|scope)|/user\.slice|/machine\.slice/[^/]+'';
          action = "keep";
        }
        {
          source_labels = [ "id" ];
          regex = ''.*/([^/]+)'';
          target_label = "unit";
        }
        {
          source_labels = [ "id" ];
          regex = "/";
          target_label = "unit";
          replacement = "host";
        }
        {
          source_labels = [ "name" ];
          regex = "(.+)";
          target_label = "unit";
          replacement = "docker:$1";
        }
      ];
    }
  ];
}
