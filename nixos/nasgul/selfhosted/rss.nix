{ config, lib, ... }:

let
  inherit (config.age) secrets;
  port = 8085;
  oidc_collback_url = "https://rss.${config.homelab.domain}/oauth2/oidc/callback";
in
{
  homelab.traefik.services.rss = { inherit port; };
  services.miniflux = {
    enable = true;
    adminCredentialsFile = secrets.miniflux_admin_credentials.path;
    config = {
      LISTEN_ADDR = "localhost:${builtins.toString port}";
      BASE_URL = "https://rss.${config.homelab.domain}";
    };
    config = {
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_USER_CREATION = "1";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.${config.homelab.domain}";
      OAUTH2_REDIRECT_URL = oidc_collback_url;
      OAUTH2_CLIENT_ID_FILE = secrets.miniflux_client_id.path;
      OAUTH2_CLIENT_SECRET_FILE = secrets.miniflux_client_secret.path;
    };
  };
  users.groups.miniflux-secrets = { };
  systemd.services.miniflux.serviceConfig.SupplementaryGroups = [ "miniflux-secrets" ];
  age.secrets = lib.genAttrs [ "miniflux_admin_credentials" "miniflux_client_id" "miniflux_client_secret" ] (name: {
    file = ../../../secrets/nasgul_${name}.age;
    mode = "0440";
    group = "miniflux-secrets";
  });
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [{
    authorization_policy = "one_factor";
    client_id = "miniflux";
    client_secret = "$pbkdf2-sha512$310000$04zWVx1B/vunExsKbVoelQ$PlGGkOG691I5YFEfY5J0uknApI63w.5xeBIsnDA0BuxXGa4ofKCw2Ze0qv1P4ES.It9XQTgB4x0UXzN/hNN6LA";
    redirect_uris = [ oidc_collback_url ];
  }];
}
