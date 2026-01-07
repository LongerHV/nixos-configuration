{ pkgs, config, ... }:

{
  services.home-assistant = {
    enable = true;
    extraPackages = ps: with ps; [ psycopg2 ];
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      "isal"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      auth_oidc
    ];
    config = {
      default_config = { };
      http = {
        server_host = [ "127.0.0.1" ];
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      recorder.db_url = "postgresql://@/hass";
      "automation ui" = "!include automations.yaml";
    };
  };
  services.postgresql = {
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensureDBOwnership = true;
    }];
  };
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0644 hass hass"
  ];
  homelab.traefik.services.hass.port = config.services.home-assistant.config.http.server_port;
}
