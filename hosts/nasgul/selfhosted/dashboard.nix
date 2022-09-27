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
        name = "Utilities";
        items = [
          {
            title = "Dashy";
            url = "https://dash.local.${config.myDomain}";
            icon = "hl-dashy";
          }
          {
            title = "Nextcloud";
            url = "https://nextcloud.local.${config.myDomain}";
            icon = "hl-nextcloud";
          }
          {
            title = "Gitea";
            url = "https://gitea.local.${config.myDomain}";
            icon = "hl-gitea";
          }
          {
            title = "Traefik";
            url = "https://traefik.local.${config.myDomain}";
            icon = "hl-traefik";
          }
          {
            title = "Authelia";
            url = "https://auth.local.${config.myDomain}";
            icon = "hl-authelia";
          }
          {
            title = "MinIO";
            url = "https://minio.local.${config.myDomain}";
            icon = "hl-minio";
          }
          rec {
            title = "Nix cache";
            url = "https://cache.local.${config.myDomain}";
            statusCheckUrl = "${url}/nix-cache-info";
            icon = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg";
          }
        ];
      }
      {
        name = "Multimedia";
        items = [
          {
            title = "Jellyfin";
            url = "https://jellyfin.local.${config.myDomain}/sso/OID/p/authelia";
            icon = "hl-jellyfin";
          }
          {
            title = "Sonarr";
            url = "https://sonarr.local.${config.myDomain}";
            icon = "hl-sonarr";
          }
          {
            title = "Radarr";
            url = "https://radarr.local.${config.myDomain}";
            icon = "hl-radarr";
          }
          {
            title = "Bazarr";
            url = "https://bazarr.local.${config.myDomain}";
            icon = "hl-bazarr";
          }
          {
            title = "Prowlarr";
            url = "https://prowlarr.local.${config.myDomain}";
            icon = "hl-prowlarr";
          }
          {
            title = "Deluge";
            url = "https://deluge.local.${config.myDomain}";
            icon = "hl-deluge";
          }
        ];
      }
      {
        name = "Monitoring";
        items = [
          {
            title = "Netdata";
            url = "https://netdata.local.${config.myDomain}";
            icon = "hl-netdata";
          }
          {
            title = "Prometheus";
            url = "https://prometheus.local.${config.myDomain}";
            icon = "hl-prometheus";
          }
          {
            title = "Grafana";
            url = "https://grafana.local.${config.myDomain}";
            icon = "hl-grafana";
          }
        ];
      }
    ];
  };
in
{
  imports = [ ./containers.nix ];

  services.dashy = {
    enable = true;
    imageTag = "2.1.1";
    port = 8082;
    inherit settings;
    extraOptions = [
      "--label"
      "traefik.http.routers.dashy.rule=Host(`dash.local.${config.myDomain}`)"
      "--label"
      "traefik.http.services.dashy.loadBalancer.server.port=8082"
      "--network=host"
      "--no-healthcheck"
    ];
  };
}
