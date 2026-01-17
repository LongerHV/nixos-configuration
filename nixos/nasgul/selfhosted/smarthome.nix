{ pkgs, config, ... }:

let
  mqttPort = 1883;
in
{
  # Matter-server seems to advertise a different port on each startup,
  # not sure how crutial it is for operation
  networking.firewall.trustedInterfaces = [ "vlan20" ];

  networking.firewall.allowedTCPPorts = [ mqttPort ]; # MQTT
  services = {
    # MQTT Broker for Valetudo
    mosquitto = {
      enable = true;
      listeners = [
        {
          port = mqttPort;
          users = {
            valetudo = {
              passwordFile = config.age.secrets.mqtt_valetudo_password.path;
              acl = [ "readwrite #" ];
            };
          };
        }
      ];
    };

    avahi = {
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
      openFirewall = true;
    };

    matter-server = {
      enable = true;
      extraArgs = [ "--primary-interface" "vlan20" ]; # Required for commissioning (requires internet access on vlan20 as well)
    };
    home-assistant = {
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
        "mqtt"
        "thread"
        "otbr"
      ];
      customComponents = with pkgs.home-assistant-custom-components; [
        auth_oidc
      ];
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        auto-entities
        valetudo-map-card
      ];
      config = {
        default_config = { };
        homeassistant = {
          internal_url = "https://hass.${config.homelab.domain}";
        };
        discovery = {
          ignore = [
            { platform = "cast"; }
            { platform = "ipp"; }
            { platform = "androidtv_remote"; }
          ];
        };
        http = {
          server_host = [ "127.0.0.1" ];
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        recorder.db_url = "postgresql://@/hass";
        lovelace.mode = "yaml";
        "automation ui" = "!include automations.yaml";
        auth_oidc = {
          client_id = "hass";
          client_secret = "!env_var HASS_OIDC_SECRET";
          discovery_url = "https://auth.${config.homelab.domain}/.well-known/openid-configuration";
          # features.automatic_user_linking = true; # Use only for initial setup to link first (admin) user created by HASS
        };
      };
    };
    postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensureDBOwnership = true;
      }];
    };
  };
  age = {
    secrets.hass_environment.file = ../../../secrets/nasgul_hass_environment.age;
    secrets.mqtt_valetudo_password.file = ../../../secrets/nasgul_mqtt_valetudo_password.age;
  };
  systemd.services.home-assistant.serviceConfig.EnvironmentFile = config.age.secrets.hass_environment.path;
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0644 hass hass"
  ];
  homelab.traefik.services.hass.port = config.services.home-assistant.config.http.server_port;
}
