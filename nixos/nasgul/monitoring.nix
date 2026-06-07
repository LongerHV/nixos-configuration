{ config, ... }:

let
  domain = "nebula.arpa";
  hosts = port: map (host: "${host}.${domain}:${port}") (builtins.attrNames config.homelab.nebula.hosts);
  inherit (config.services.prometheus.exporters)
    node
    smartctl
    systemd
    ;
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
  ];
}
