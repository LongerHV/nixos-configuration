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
            url = "http://localhost:8989";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Radarr";
            url = "http://localhost:7878";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Bazarr";
            url = "http://localhost:6767";
            icon = "${url}/static/favicon.ico";
            statusCheck = true;
          }
          {
            title = "Prowlarr";
            url = "http://localhost:9696";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Transmission";
            url = "http://localhost:9091";
            icon = "${url}/transmission/web/images/favicon.ico";
            statusCheck = true;
          }
        ];
      }
      {
        name = "Monitoring";
        items = [
          {
            title = "Netdata";
            url = "localhost:19999";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Prometheus";
            url = "localhost:9090";
            icon = "favicon";
            statusCheck = true;
          }
          rec {
            title = "Grafana";
            url = "localhost:300q";
            icon = "${url}/public/img/grafana_icon.svg";
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
    inherit settings;
    extraOptions = [
      "--label"
      "traefik.http.routers.dashy.rule=Host(`dash.local.${config.myDomain}`)"
      "--label"
      "traefik.http.services.dashy.loadBalancer.server.port=80"
      "--dns"
      "192.168.1.243"
    ];
  };
}
