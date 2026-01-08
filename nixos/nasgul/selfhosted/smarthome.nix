{ pkgs, config, ... }:

{
  # Matter-server seems to advertise a different port on each startup,
  # not sure how crutial it is for operation
  # networking.firewall.trustedInterfaces = [ "vlan20" ];

  networking.firewall.allowedUDPPorts = [ 5353 ]; # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    allowInterfaces = [ "eth0" "vlan20" ];
  };

  services.matter-server = {
    enable = true;
    # extraArgs = [ "--primary-interface" "vlan20" ];
  };
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

      "matter"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      auth_oidc
    ];
    config = {
      default_config = { };
      homeassistant = {
        internal_url = "https://hass.${config.homelab.domain}";
      };
      http = {
        server_host = [ "127.0.0.1" ];
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      recorder.db_url = "postgresql://@/hass";
      "automation ui" = "!include automations.yaml";
      auth_oidc = {
        client_id = "hass";
        client_secret = "!env_var HASS_OIDC_SECRET";
        discovery_url = "https://auth.${config.homelab.domain}/.well-known/openid-configuration";
        # features.automatic_user_linking = true; # Use only for initial setup to link first (admin) user created by HASS
      };
    };
  };
  age.secrets.hass_environment.file = ../../../secrets/nasgul_hass_environment.age;
  systemd.services.home-assistant.serviceConfig.EnvironmentFile = config.age.secrets.hass_environment.path;
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
