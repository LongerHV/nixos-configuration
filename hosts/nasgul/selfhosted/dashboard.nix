{ config, pkgs, ... }:

let
  settings = {
    pageInfo = {
      title = "Longer's homelab";
      description = "Nyaa~~";
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
      theme = "one-dark";
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
