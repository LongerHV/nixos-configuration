{ config, pkgs, ... }:

{
  # /etc/hosts entries for dashy, to bypass authelia during status checks
  networking.hosts."127.0.0.1" = map (subdomain: "${subdomain}.${config.homelab.domain}") [
    "auth"
    "bazarr"
    "blocky"
    "deluge"
    "grafana"
    "netdata"
    "prometheus"
    "prowlarr"
    "radarr"
    "rss"
    "sonarr"
    "traefik"
    "yt"
  ];

  homelab.traefik.services.dash.port = 8082;

  nixpkgs.config.permittedInsecurePackages = [ "nodejs-16.20.1" ];
  services.dashy = {
    enable = true;
    port = 8082;
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
              url = "https://nextcloud.${config.homelab.domain}";
              icon = "hl-nextcloud";
            }
            {
              title = "Gitea";
              url = "https://gitea.${config.homelab.domain}";
              icon = "hl-gitea";
            }
            {
              title = "Jellyfin";
              url = "https://jellyfin.${config.homelab.domain}/sso/OID/p/authelia";
              icon = "hl-jellyfin";
            }
            {
              title = "Invidious";
              url = "https://yt.${config.homelab.domain}";
              icon = "hl-invidious";
            }
            {
              title = "Miniflux";
              url = "https://rss.${config.homelab.domain}";
              icon = "hl-miniflux";
            }
          ];
        }
        {
          name = "Utilities";
          items = [
            {
              title = "Dashy";
              url = "https://dash.${config.homelab.domain}";
              # icon = "hl-dashy"; # Broken for some reason
              icon = "https://raw.githubusercontent.com/walkxcode/Dashboard-Icons/main/png/dashy.png";
            }
            {
              title = "Traefik";
              url = "https://traefik.${config.homelab.domain}";
              icon = "hl-traefik";
            }
            {
              title = "Blocky";
              url = "https://blocky.${config.homelab.domain}";
              # icon = "hl-blocky"; # Waiting for a new Dashy release using proper icons repo (https://github.com/Lissy93/dashy/issues/972)
              icon = "https://raw.githubusercontent.com/walkxcode/Dashboard-Icons/main/png/blocky.png";
            }
            {
              title = "LLDAP";
              url = "https://ldap.${config.homelab.domain}";
            }
            {
              title = "Authelia";
              url = "https://auth.${config.homelab.domain}";
              icon = "hl-authelia";
            }
            rec {
              title = "Nix cache";
              url = "https://cache.${config.homelab.domain}";
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
              url = "https://sonarr.${config.homelab.domain}";
              icon = "hl-sonarr";
            }
            {
              title = "Radarr";
              url = "https://radarr.${config.homelab.domain}";
              icon = "hl-radarr";
            }
            {
              title = "Bazarr";
              url = "https://bazarr.${config.homelab.domain}";
              icon = "hl-bazarr";
            }
            {
              title = "Readarr";
              url = "https://readarr.${config.homelab.domain}";
              icon = "hl-readarr";
            }
            {
              title = "Prowlarr";
              url = "https://prowlarr.${config.homelab.domain}";
              icon = "hl-prowlarr";
            }
            {
              title = "Deluge";
              url = "https://deluge.${config.homelab.domain}";
              icon = "hl-deluge";
            }
          ];
        }
        {
          name = "Monitoring";
          items = [
            {
              title = "Netdata";
              url = "https://netdata.${config.homelab.domain}";
              icon = "hl-netdata";
            }
            {
              title = "Prometheus";
              url = "https://prometheus.${config.homelab.domain}";
              icon = "hl-prometheus";
            }
            {
              title = "Grafana";
              url = "https://grafana.${config.homelab.domain}";
              icon = "hl-grafana";
            }
          ];
        }
      ];
    };
  };
}
