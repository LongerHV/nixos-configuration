{
  homelab.traefik.services.netdata.port = 19999;

  services = {
    prometheus.scrapeConfigs = [{
      job_name = "openwrt";
      static_configs = [{
        targets = [
          "10.123.1.1:9100"
          "10.123.1.2:9100"
          "10.123.1.3:9100"
          "10.123.1.4:9100"
        ];
      }];
    }];
    grafana.provision.dashboards.settings.providers = [{
      name = "openwrt";
      options.path = ../../../modules/nixos/homelab/dashboards/openwrt.json;
    }];
  };
}
