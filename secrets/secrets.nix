let
  inherit (import ./secrets_keys.nix) nasgul angmar mordor mordor_user backup;
in
{
  # Tokens
  "extra_access_tokens.age".publicKeys = [ nasgul mordor mordor_user ];

  # Nasgul
  "nasgul_wireguard_priv_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_mullvad_priv_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_cache_priv_key.pem.age".publicKeys = [ nasgul mordor_user ];
  "authelia_jwt_secret.age".publicKeys = [ nasgul mordor_user ];
  "authelia_storage_encryption_key.age".publicKeys = [ nasgul mordor_user ];
  "authelia_hmac_secret.age".publicKeys = [ nasgul mordor_user ];
  "authelia_issuer_private_key.age".publicKeys = [ nasgul mordor_user ];
  "authelia_mysql_password.age".publicKeys = [ nasgul mordor_user ];
  "nextcloud_admin_password.age".publicKeys = [ nasgul mordor_user ];
  "authelia_session_secret.age".publicKeys = [ nasgul mordor_user ];
  "ldap_password.age".publicKeys = [ nasgul mordor_user ];
  "sendgrid_token.age".publicKeys = [ nasgul angmar mordor_user ];
  "gitea_actions_token.age".publicKeys = [ nasgul mordor_user ];
  "restic_s3_key.age".publicKeys = [ nasgul angmar mordor_user ];
  "restic_password.age".publicKeys = [ nasgul angmar mordor_user backup ];
  "lldap_private_key.age".publicKeys = [ nasgul mordor_user ];
  "lldap_jwt_secret.age".publicKeys = [ nasgul mordor_user ];
  "lldap_user_pass.age".publicKeys = [ nasgul mordor_user ];
  "miniflux_admin_credentials.age".publicKeys = [ nasgul mordor_user ];
  "miniflux_client_id.age".publicKeys = [ nasgul mordor_user ];
  "miniflux_client_secret.age".publicKeys = [ nasgul mordor_user ];
  "anki_password.age".publicKeys = [ nasgul mordor_user ];
  "hass_environment.age".publicKeys = [ nasgul mordor_user ];
  "mqtt_valetudo_password.age".publicKeys = [ nasgul mordor_user ];
  "grafana_environment.age".publicKeys = [ nasgul mordor_user ];
  "vikunja_environment.age".publicKeys = [ nasgul mordor_user ];
  "hermes_env.age".publicKeys = [ nasgul mordor mordor_user ];
  "tuwunel_registration_token.age".publicKeys = [ nasgul mordor_user ];
  "hermes_matrix_env.age".publicKeys = [ nasgul mordor_user ];
  "cloudflare_token.age".publicKeys = [ nasgul angmar mordor_user ];
  "cloudflare_email.age".publicKeys = [ nasgul angmar mordor_user ];
  "valheim_environment.age".publicKeys = [ angmar mordor_user ];

  # Mordor
  "mordor_cache_priv_key.pem.age".publicKeys = [ mordor mordor_user ];
  "mordor_mullvad_priv_key.age".publicKeys = [ mordor mordor_user ];
}
