let
  inherit (import ./secrets_keys.nix) nasgul mordor mordor_user backup;
in
{
  # Tokens
  "extra_access_tokens.age".publicKeys = [ nasgul mordor mordor_user ];

  # Nasgul
  "nasgul_wireguard_priv_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_mullvad_priv_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_cache_priv_key.pem.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_jwt_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_storage_encryption_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_hmac_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_issuer_private_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_mysql_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_nextcloud_admin_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_session_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_ldap_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_sendgrid_token.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_gitea_actions_token.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_restic_s3_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_restic_password.age".publicKeys = [ nasgul mordor_user backup ];
  "nasgul_lldap_private_key.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_lldap_jwt_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_lldap_user_pass.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_miniflux_admin_credentials.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_miniflux_client_id.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_miniflux_client_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_anki_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_hass_environment.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_mqtt_valetudo_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_grafana_environment.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_vikunja_environment.age".publicKeys = [ nasgul mordor_user ];
  "cloudflare_token.age".publicKeys = [ nasgul mordor_user ];
  "cloudflare_email.age".publicKeys = [ nasgul mordor_user ];

  # Mordor
  "mordor_cache_priv_key.pem.age".publicKeys = [ mordor mordor_user ];
  "mordor_mullvad_priv_key.age".publicKeys = [ mordor mordor_user ];
}
