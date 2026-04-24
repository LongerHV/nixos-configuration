let
  domain = "nebula.arpa";
  hosts = port: map (host: "${host}.${domain}:${port}") [
    "mordor"
    "palantir"
  ];
in
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{ targets = hosts "9100"; }];
    }
    {
      job_name = "smartctl";
      static_configs = [{ targets = hosts "9633"; }];
    }
  ];
}
