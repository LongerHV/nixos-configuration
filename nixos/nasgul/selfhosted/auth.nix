{ config, lib, ... }:

let
  inherit (config.homelab) domain;
in
{
  homelab = {
    # Authelia runs on angmar (nixos/angmar/selfhosted/auth.nix), reached over nebula.
    auth.autheliaUrl = "http://${config.homelab.nebula.hosts.angmar}:9092";

    traefik.services = lib.genAttrs [
      "bazarr"
      "blocky"
      "deluge"
      "matter"
      "prometheus"
      "prowlarr"
      "radarr"
      "readarr"
      "sonarr"
      "victorialogs"
    ]
      (_: { middlewares = [ "authelia" ]; });

    # OIDC clients of nasgul's services; angmar's Authelia picks these up, so
    # deploy angmar after changing them.
    auth.oidc = {
      claims_policies.grafana.id_token = [ "email" "name" "groups" "preferred_username" ];
      clients = [
        {
          authorization_policy = "one_factor";
          client_id = "jellyfin";
          client_secret = "$pbkdf2-sha512$310000$rMliY0u1kEQ0FRHrG8xvqg$8.wKSra2uT5VFhCAv1YQHHnCSSORmWDrdAv6Uns1Ae7yu24w87SW0PmH9BKrYB1YIWoo7RJhF1NtYupQ.YRyRg";
          redirect_uris = [ "https://jellyfin.${domain}/sso/OID/r/authelia" ];
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          authorization_policy = "one_factor";
          client_id = "gitea";
          client_secret = "$pbkdf2-sha512$310000$g7mufVXry1vsC5uk7KSohw$EIt7XiOdxayh8on7OCZgiLWCmRTzLW9a8Cupnoyh/aeX2M6n7Hi/KCVW7f4xk3l8pk7RFfjTGLzbqbp6FtyDYQ";
          redirect_uris = [ "https://gitea.${domain}/user/oauth2/Authelia/callback" ];
        }
        {
          authorization_policy = "one_factor";
          client_id = "immich";
          client_secret = "$pbkdf2-sha512$310000$wPpdmhrPqd.dU.tcLTh9nQ$du11GENjjxaXf5njeqnhpVgr8O9fCISulobjRStCsYJzY6i3aaOyiloRJHKDh.CC.4n1QVqsP.ty9Lo8UH3XvA";
          redirect_uris = [ "https://immich.${domain}/auth/login" "https://immich.${domain}/user-settings" "app.immich:///oauth-callback" ];
          scopes = [ "openid" "profile" "email" ];
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          authorization_policy = "one_factor";
          client_id = "hass";
          client_secret = "$pbkdf2-sha512$310000$TmV7cKFBk1KoulcsQ1kqlw$vqSdVZIqzZZCrxXLkVXo4ShfzbkMJUq7wpyIV4v/3ucV6vykYnl7vlEtflSXOl1RqYI5rWJ5kkXQkYbuXwLBlw";
          public = false;
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://hass.${domain}/auth/oidc/callback" ];
          scopes = [ "openid" "profile" "groups" ];
          id_token_signed_response_alg = "RS256";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          authorization_policy = "one_factor";
          client_id = "grafana";
          claims_policy = "grafana";
          client_secret = "$pbkdf2-sha512$310000$vKuvSI9sG6Z5GdMsHAsTEA$Ptkt7FR5zL5.REh6P/yz9vR4BZhq.sQVoiJ7i38pgroVf.ppPcsoWaNYIQ/T6yl/3vrxqT7U3WnwxKZrnOQdng";
          public = false;
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://grafana.${domain}/login/generic_oauth" ];
          scopes = [ "openid" "profile" "email" "groups" ];
          response_types = [ "code" ];
          grant_types = [ "authorization_code" ];
          access_token_signed_response_alg = "RS256";
          id_token_signed_response_alg = "RS256";
          token_endpoint_auth_method = "client_secret_basic";
        }
        {
          authorization_policy = "one_factor";
          client_id = "vikunja";
          client_secret = "$pbkdf2-sha512$310000$6IgqlpawwrXgBMczZfFmyA$8My4BtEG.LO86BQYCbT35ttEwGmSXbuwO2fDUM54Z4M0Rz46n3n.L4zkHwxY5GpVNZNsAMsMm1rpODO0jH9dxA";
          redirect_uris = [ "https://vikunja.${domain}/auth/openid/authelia" ];
          scopes = [ "openid" "profile" "email" ];
          token_endpoint_auth_method = "client_secret_basic";
        }
      ];
    };
  };
}
