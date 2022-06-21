{ config, pkgs, ... }:

let
  settings = {
    pageInfo = {
      title = "Longer's homelab";
      description = "Nyaa~~";
      faviconApi = "local";
      navLinks = [
        {
          title = "GitHub";
          path = "https://github.com/Lissy93/dashy";
        }
        {
          title = "Documentation";
          path = "https://dashy.to/docs";
        }
      ];
    };
    appConfig = {
      theme = "nord-frost";
      layout = "auto";
      iconSize = "medium";
      language = "pl";
    };
    sections = [
      {
        name = "Multimedia";
        items = [
          {
            title = "Sonarr";
            url = "https://sonarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Radarr";
            url = "https://radarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Prowlarr";
            url = "https://prowlarr.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Jellyfin";
            url = "https://jellyfin.local.${config.myDomain}";
            icon = "favicon";
            statusCheck = true;
          }
          {
            title = "Transmission";
            url = "https://transmission.local.${config.myDomain}";
            icon = "favicon";
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
