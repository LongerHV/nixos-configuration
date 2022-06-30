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
      faviconApi = "local";
      hideComponents.hideSettings = true;
    };
    sections = [
      {
        name = "Utilities";
        items = [
          {
            title = "Dashy";
            url = "https://dash.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Nextcloud";
            url = "https://nextcloud.local.${config.myDomain}";
            icon = "${url}/core/img/favicon.ico";
            statusCheck = true;
          }
          {
            title = "Gitea";
            url = "https://gitea.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Traefik";
            url = "https://traefik.local.${config.myDomain}";
            icon = "${url}/dashboard/statics/icons/favicon.ico";
            statusCheckUrl = "http://localhost:8080";
            statusCheck = true;
          }
          rec {
            title = "Authelia";
            url = "https://auth.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Nix cache";
            url = "https://cache.local.${config.myDomain}";
            statusCheckUrl = "${url}/nix-cache-info";
            icon = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg";
            statusCheck = true;
          }
        ];
      }
      {
        name = "Multimedia";
        items = [
          rec {
            title = "Jellyfin";
            url = "https://jellyfin.local.${config.myDomain}/sso/OID/p/authelia";
            icon = "${statusCheckUrl}/web/favicon.ico";
            statusCheckUrl = "https://jellyfin.local.${config.myDomain}";
            statusCheck = true;
          }
          {
            title = "Sonarr";
            url = "https://sonarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheckUrl = "http://localhost:8989";
            statusCheck = true;
          }
          {
            title = "Radarr";
            url = "https://radarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheckUrl = "http://localhost:7878";
            statusCheck = true;
          }
          rec {
            title = "Bazarr";
            url = "https://bazarr.local.${config.myDomain}";
            icon = "${url}/static/favicon.ico";
            statusCheckUrl = "http://localhost:6767";
            statusCheck = true;
          }
          {
            title = "Prowlarr";
            url = "https://prowlarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheckUrl = "http://localhost:9696";
            statusCheck = true;
          }
          rec {
            title = "Deluge";
            url = "https://deluge.local.${config.myDomain}";
            icon = "${url}/icons/deluge.png";
            statusCheckUrl = "http://localhost:8112";
            statusCheck = true;
          }
        ];
      }
      {
        name = "Monitoring";
        items = [
          {
            title = "Netdata";
            url = "https://netdata.local.${config.myDomain}";
            icon = "favicon";
            statusCheckUrl = "http://localhost:19999";
            statusCheck = true;
          }
          {
            title = "Prometheus";
            url = "https://prometheus.local.${config.myDomain}";
            icon = "favicon";
            statusCheckUrl = "http://localhost:9090";
            statusCheck = true;
          }
          rec {
            title = "Grafana";
            url = "https://grafana.local.${config.myDomain}";
            icon = "${url}/public/img/grafana_icon.svg";
            statusCheckUrl = "http://localhost:3001";
            statusCheck = true;
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
    imageTag = "2.1.0";
    port = 8082;
    inherit settings;
    extraOptions = [
      "--label"
      "traefik.http.routers.dashy.rule=Host(`dash.local.${config.myDomain}`)"
      "--label"
      "traefik.http.services.dashy.loadBalancer.server.port=8082"
      # "--dns"
      # "192.168.1.243"
      "--network=host"
      "--no-healthcheck"
    ];
  };
}
