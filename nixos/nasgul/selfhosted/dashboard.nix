{ config, pkgs, ... }:

let
  settings = {
    pageInfo = {
      title = "Longer's homelab";
      description = "Nyaa~~";
      navLinks = [
        {
          title = "GitHub";
          path = "https://github.com/LongerHV";
        }
        {
          title = "GitLab";
          path = "https://gitlab.com/LongerHV";
        }

      ];
    };
    appConfig = {
      theme = "nord-frost";
      layout = "auto";
      iconSize = "large";
      language = "pl";
      statusCheck = true;
      hideComponents.hideSettings = true;
    };
    sections = [
      {
        name = "Services";
        items = [
          {
            title = "Nextcloud";
            url = "https://nextcloud.${config.myDomain}";
            icon = "hl-nextcloud";
          }
          {
            title = "Gitea";
            url = "https://gitea.${config.myDomain}";
            icon = "hl-gitea";
          }
          {
            title = "Jellyfin";
            url = "https://jellyfin.${config.myDomain}/sso/OID/p/authelia";
            icon = "hl-jellyfin";
          }
        ];
      }
      {
        name = "Utilities";
        items = [
          {
            title = "Dashy";
            url = "https://dash.${config.myDomain}";
            # icon = "hl-dashy"; # Broken for some reason
            icon = "https://raw.githubusercontent.com/walkxcode/Dashboard-Icons/main/png/dashy.png";
          }
          {
            title = "Traefik";
            url = "https://traefik.${config.myDomain}";
            icon = "hl-traefik";
          }
          {
            title = "Blocky";
            url = "https://blocky.${config.myDomain}";
            # icon = "hl-blocky"; # Waiting for a new Dashy release using proper icons repo (https://github.com/Lissy93/dashy/issues/972)
            icon = "https://raw.githubusercontent.com/walkxcode/Dashboard-Icons/main/png/blocky.png";
          }
          {
            title = "LLDAP";
            url = "https://ldap.${config.myDomain}";
          }
          {
            title = "Authelia";
            url = "https://auth.${config.myDomain}";
            icon = "hl-authelia";
          }
          rec {
            title = "Nix cache";
            url = "https://cache.${config.myDomain}";
            statusCheckUrl = "${url}/nix-cache-info";
            icon = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg";
          }
        ];
      }
      {
        name = "Multimedia";
        items = [
          {
            title = "Sonarr";
            url = "https://sonarr.${config.myDomain}";
            icon = "hl-sonarr";
          }
          {
            title = "Radarr";
            url = "https://radarr.${config.myDomain}";
            icon = "hl-radarr";
          }
          {
            title = "Bazarr";
            url = "https://bazarr.${config.myDomain}";
            icon = "hl-bazarr";
          }
          {
            title = "Prowlarr";
            url = "https://prowlarr.${config.myDomain}";
            icon = "hl-prowlarr";
          }
          {
            title = "Deluge";
            url = "https://deluge.${config.myDomain}";
            icon = "hl-deluge";
          }
        ];
      }
      {
        name = "Monitoring";
        items = [
          {
            title = "Netdata";
            url = "https://netdata.${config.myDomain}";
            icon = "hl-netdata";
          }
          {
            title = "Prometheus";
            url = "https://prometheus.${config.myDomain}";
            icon = "hl-prometheus";
          }
          {
            title = "Grafana";
            url = "https://grafana.${config.myDomain}";
            icon = "hl-grafana";
          }
        ];
      }
    ];
  };
in
{
  # /etc/hosts entries for dashy, to bypass authelia during status checks
  networking.hosts."127.0.0.1" = map (subdomain: "${subdomain}.${config.myDomain}") [
    "traefik"
    "blocky"
    "sonarr"
    "radarr"
    "bazarr"
    "prowlarr"
    "deluge"
    "netdata"
    "prometheus"
    "grafana"
  ];

  homelab.traefik.services.dash.port = 8082;

  services.dashy = {
    enable = true;
    port = 8082;
    inherit settings;
  };
}
