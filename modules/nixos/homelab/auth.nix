{ config, pkgs, lib, ... }:

let
  cfg = config.homelab.auth;
  forwardAuth = query: {
    address = "${cfg.autheliaUrl}/api/verify${query}";
    trustForwardHeader = true;
    authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
  };
in
{
  options.homelab.auth = {
    # Authelia OIDC provider settings (clients, authorization_policies,
    # claims_policies) declared next to the services that use them, on
    # whichever host runs that service. The host running Authelia merges its
    # own with the other hosts' declarations.
    oidc = lib.mkOption {
      inherit (pkgs.formats.yaml { }) type;
      default = { };
    };
    # Where this host's Traefik reaches Authelia for forward auth.
    autheliaUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://127.0.0.1:9092";
    };
  };

  config = lib.mkIf (cfg.autheliaUrl != null && config.homelab.traefik.enable) {
    services.traefik.dynamicConfigOptions.http = {
      routers.traefik.middlewares = [ "authelia" ];
      middlewares = {
        authelia.forwardAuth = forwardAuth "?rd=https%3A%2F%2Fauth.${config.homelab.domain}%2F";
        authelia-basic.forwardAuth = forwardAuth "?auth=basic";
      };
    };
  };
}
