{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.traefik;
  hasTLS = cfg.cloudflareTLS.enable;

  serviceOptions = _: with lib; {
    options = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      port = mkOption {
        type = types.port;
      };
      local = mkOption {
        type = types.bool;
        default = true;
      };
      authelia = mkOption {
        type = types.bool;
        default = false;
      };
      middlewares = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  mkService = name: value: {
    loadBalancer = {
      servers = [
        { url = "http://${value.host}:${builtins.toString value.port}"; }
      ];
    };
  };
  mkRouter = name: value:
    let
      prefix = if value.local then "${name}.local" else "${name}";
      domain = "${prefix}.${hl.domain}";
      whitelist = if value.local then "local-ip-whitelist" else "external-ip-whitelist";
    in
    {
      rule = "Host(`${domain}`)";
      service = "${name}";
      middlewares = value.middlewares ++ [ whitelist ] ++ (lib.lists.optional value.authelia "authelia");
    };
in
{
  options.homelab.traefik = with lib; {
    enable = mkEnableOption "traefik";
    docker.enable = mkEnableOption "docker" // { default = config.virtualisation.docker.enable; };
    services = mkOption {
      type = types.attrsOf (types.submodule serviceOptions);
      default = { };
    };
    cloudflareTLS = {
      enable = mkEnableOption "cloudflareTLS";
      apiEmailFile = lib.mkOption {
        type = types.str;
      };
      dnsApiTokenFile = lib.mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 ] ++ lib.lists.optional hasTLS 443;
    systemd.services.traefik.environment = lib.mkIf hasTLS {
      CF_API_EMAIL_FILE = cfg.cloudflareTLS.apiEmailFile;
      CF_DNS_API_TOKEN_FILE = cfg.cloudflareTLS.dnsApiTokenFile;
    };

    services.traefik = {
      enable = true;
      group = lib.mkIf cfg.docker.enable "docker";
      staticConfigOptions = lib.recursiveUpdate
        {
          log.level = "info";
          providers = lib.mkIf cfg.docker.enable { docker = { }; };
          entryPoints = {
            web = {
              address = ":80";
            };
          };
          api = {
            insecure = true;
            dashboard = true;
          };
        }
        (lib.optionalAttrs hasTLS {
          entryPoints = {
            web = {
              http.redirections.entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
            websecure = {
              address = ":443";
              http.tls = {
                certResolver = "cloudflare";
                domains = [{ main = "${hl.domain}"; sans = [ "*.${hl.domain}" ]; }];
              };
            };
          };
          certificatesResolvers = {
            cloudflare = {
              acme = {
                email = "michal@mieszczak.com.pl";
                storage = "${config.services.traefik.dataDir}/acme.json";
                dnsChallenge = {
                  provider = "cloudflare";
                  resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
                };
              };
            };
          };
        });
      dynamicConfigOptions = {
        http = {
          routers = builtins.mapAttrs mkRouter cfg.services;
          services = builtins.mapAttrs mkService cfg.services;
          middlewares = {
            local-ip-whitelist.IPWhiteList = {
              sourceRange = [
                "127.0.0.1/32"
                "10.0.0.0/8"
                "172.16.0.0/12"
                "192.168.0.0/16"
              ];
            };
            # TODO: Add cloudflare proxy ip ranges if I ever decide to open this to the internet
            external-ip-whitelist.IPWhiteList = {
              sourceRange = [ ];
            };
          };
        };
      };
    };
  };
}
