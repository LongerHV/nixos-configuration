{ config, pkgs, ... }:

let
  util = pkgs.callPackage ./util.nix { inherit config; };
  tlsDomains = [
    {
      main = "${config.myDomain}";
      sans = [ "*.${config.myDomain}" ];
    }
    # {
    #   main = "local.${config.myDomain}";
    #   sans = [ "*.local.${config.myDomain}" ];
    # }
  ];
  inherit (config.age) secrets;
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  age.secrets = {
    cloudflare_email = {
      file = ../../../secrets/cloudflare_email.age;
      owner = "traefik";
    };
    cloudflare_token = {
      file = ../../../secrets/cloudflare_token.age;
      owner = "traefik";
    };
  };

  users.users."${config.mainUser}".extraGroups = [ "traefik" ];

  systemd.services.traefik.environment = {
    CF_API_EMAIL_FILE = config.age.secrets.cloudflare_email.path;
    CF_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare_token.path;
  };

  services.traefik = {
    enable = true;
    # group = "docker";
    staticConfigOptions = {
      log.level = "info";
      # providers.docker = { };
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "cloudflare";
            domains = tlsDomains;
          };
        };
      };
      api = {
        insecure = true;
        dashboard = true;
      };
      certificatesResolvers.cloudflare = {
        acme = {
          email = "michal@mieszczak.com.pl";
          storage = "${config.services.traefik.dataDir}/acme.json";
          dnsChallenge = {
            provider = "cloudflare";
            resolvers = [
              "1.1.1.1:53"
              "1.0.0.1:53"
            ];
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          nextcloud-redirectregex.redirectRegex = {
            permanent = true;
            regex = "https://(.*)/.well-known/(card|cal)dav";
            replacement = "https://\${1}/remote.php/dav/";
          };
          local-ip-whitelist.IPWhiteList = {
            sourceRange = [ "192.168.1.1/24" ];
          };
          # TODO: Add cloudflare proxy ip ranges if I ever decide to open this to the internet
          external-ip-whitelist.IPWhiteList = {
            sourceRange = [];
          };
        };
        routers.cache_router = util.traefik_router { subdomain = "cache"; };
        services.cache_service = util.traefik_service { port = 5000; };
      };
    };
  };
}
