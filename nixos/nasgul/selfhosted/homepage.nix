{ config, ... }:

let
  inherit (config.homelab) domain;
in
{
  homelab.traefik.services.homepage.port = config.services.homepage-dashboard.listenPort;
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.${domain}";
    settings = {
      title = "Longer's Homelab";
    };
    services = [
      {
        Services = [
          {
            Nextcloud = {
              href = "https://nextcloud.${domain}";
              icon = "nextcloud";
            };
          }
          {
            Gitea = {
              href = "https://gitea.${domain}";
              icon = "gitea";
            };
          }
          {
            Miniflux = {
              href = "https://rss.${domain}";
              icon = "miniflux";
            };
          }
          {
            Immich = {
              href = "https://immich.${domain}";
              icon = "immich";
            };
          }
          {
            Home-Assistant = {
              href = "https://hass.${domain}";
              icon = "home-assistant";
            };
          }
          {
            "Home-Assistant (OIDC)" = {
              href = "https://hass.${domain}/auth/oidc/welcome";
              icon = "home-assistant";
            };
          }
          {
            ESPHome = {
              href = "https://esphome.${domain}";
              icon = "esphome";
            };
          }
          {
            Matter = {
              href = "https://matter.${domain}";
              icon = "matter";
            };
          }
        ];
      }
      {
        Utilities = [
          {
            Traefik = {
              href = "https://traefik.${domain}";
              icon = "traefik";
            };
          }
          {
            Blocky = {
              href = "https://blocky.${domain}";
              icon = "blocky";
            };
          }
          {
            LLDAP = {
              href = "https://ldap.${domain}";
            };
          }
          {
            Authelia = {
              href = "https://auth.${domain}";
              icon = "authelia";
            };
          }
        ];
      }
      {
        Multimedia = [
          {
            Jellyfin = {
              icon = "jellyfin";
              href = "https://jellyfin.${domain}";
            };
          }
          {
            Sonarr = {
              icon = "sonarr";
              href = "https://sonarr.${domain}";
            };
          }
          {
            Radarr = {
              icon = "radarr";
              href = "https://radarr.${domain}";
            };
          }
          {
            Bazarr = {
              icon = "bazarr";
              href = "https://bazarr.${domain}";
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr";
              href = "https://prowlarr.${domain}";
            };
          }
          {
            Readarr = {
              icon = "readarr";
              href = "https://readarr.${domain}";
            };
          }
          {
            Deluge = {
              icon = "deluge";
              href = "https://deluge.${domain}";
            };
          }
        ];
      }
      {
        Monitoring = [
          {
            Prometheus = {
              href = "https://prometheus.${domain}";
              icon = "prometheus";
            };
          }
          {
            Grafana = {
              href = "https://grafana.${domain}";
              icon = "grafana";
            };
          }
        ];
      }
    ];
    bookmarks = [
      {
        Developer = [
          {
            Github = [{
              icon = "si-github";
              href = "https://github.com/";
            }];
          }
          {
            "Nixos Search" = [{
              icon = "si-nixos";
              href = "https://search.nixos.org/packages";
            }];
          }
          {
            "Nixos Wiki" = [{
              icon = "si-nixos";
              href = "https://nixos.wiki/";
            }];
          }
          {
            "Kubernetes Docs" = [{
              icon = "si-kubernetes";
              href = "https://kubernetes.io/docs/home/";
            }];
          }
        ];
      }
    ];
  };
}
