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
          }
        ];
      }
    ];
  };
  configFile = pkgs.writeTextFile {
    name = "conf.yml";
    text = builtins.toJSON settings;
  };
in
{
  imports = [ ./containers.nix ];

  virtualisation.oci-containers.containers = {
    dashy = {
      image = "lissy93/dashy:2.1.0";
      environment = {
        TZ = "${config.time.timeZone}";
      };
      extraOptions = [
        "--label"
        "traefik.http.routers.dashy.rule=Host(`dash.local.${config.myDomain}`)"
        "--label"
        "traefik.http.services.dashy.loadBalancer.server.port=80"
      ];
      volumes = [
        "${configFile}:/app/public/conf.yml:ro"
      ];
    };
  };
}
