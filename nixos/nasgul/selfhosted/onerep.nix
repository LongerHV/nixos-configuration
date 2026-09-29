{ config, ... }:

let
  uid = 1501;
  gid = 1501;
  stateDir = "/var/lib/onerep";
  hl = config.homelab;
  domain = "onerep.${hl.domain}";
in
{
  users = {
    users = {
      "${config.mySystem.user}".extraGroups = [ "onerep" ];
      onerep = {
        isSystemUser = true;
        createHome = true;
        home = stateDir;
        homeMode = "0770";
        group = "onerep";
        inherit uid;
      };
    };
    groups.onerep = {
      inherit gid;
    };
  };

  virtualisation.oci-containers.containers.onerep = {
    image = "ghcr.io/longerhv/onerep:edge";
    autoStart = true;
    autoRemoveOnStop = false;
    ports = [ "127.0.0.1:8088:8080" ];
    environment = {
      ONEREP_DB = "/data/onerep.db";
      ONEREP_BASE_URL = "https://${domain}";
      ONEREP_OIDC_ISSUER = "https://auth.${hl.domain}";
      ONEREP_OIDC_CLIENT_ID = "onerep";
    };
    volumes = [
      "${stateDir}:/data"
    ];
    labels = {
      "traefik.http.routers.onerep.rule" = "Host(`onerep.local.longerhv.xyz`)";
    };
    user = "${toString uid}:${toString gid}";
    # Docker host IP for container to reach host services (like auth)
    extraOptions = [ "--dns" "172.17.0.1" ];
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [{
    client_id = "onerep";
    client_name = "onerep";
    public = true;
    token_endpoint_auth_method = "none";
    require_pkce = true;
    pkce_challenge_method = "S256";
    authorization_policy = "hermes";
    redirect_uris = [ "https://${domain}/auth/callback" ];
    scopes = [ "openid" "profile" "email" ];
  }];
}
