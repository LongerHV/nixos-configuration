let
  # User key
  mordor_user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCLO8jWFPCx141QQyBBSGFSEY1iGwrcrb0NnNfjDHopx+FDPSo3d8Rat9sMqojL9o80frLxU/SpkC/9BddCu7dqlmPFEt2rNvzG2Evv+Epovr/hHD5EeJP7fNdW+FqoODIK9GOJLstc5h8m7LdMwEpI7FlSVRbhBFhiwwhdbIlGNnFogDggjc9WIux5oyzY6i3O/GNeP/G9Mwi8STGGKS0yuBVtVmsJ+zakrXWpSAhm4N0OSZzxUKGAzLWCs67VnF4VM+/nhCqro9jlpORDyM19AmMtAC/M2NI8T/Um0UaUm/I3wFkOCRqRdbNk6M6pCmTGm6jOszugNjb8zUH4lT1KfSZbo/GIO0Lyxi3bPCQFQLl0r6aVMn0AIOkkNmPg4LvVa7ux9FlaE1qjEoe6TtkZ2i50+4FWWS2ZcFJpiNDQ8crc4TNnrjeOkye4E//gw+6ki3UaTETR7ZwsnnjiTLFw2aJcP8BGOZBVvjmkKSIZ6cLhyo0rc+yamxcWaCup27g8xxLlD6CXDwmvRz04KyxUJf6eBGmX58d3m2zhbDC9pJXh0I5HtbOydTLgY7wDFnLx9p6yNPSLyD4jotKJdCH5IjFL1s41/YzpunkhNRyWvNCLUBS5xiE+4BmFcTFWsov1dwd3+uriR5/Q7iMCnvl2kadAkRcjCcLR3vJKNwfqQ==";

  # Host key
  nasgul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2gRPWw7Ijjn6rNB+2I/97osC6AqarGOsw9jhxzUdAi";
  mordor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdT6E0OwCh/fF1ji0ExyH+4zhh1znuoT+sCeDgYn9N1";

  # Backup keys
  backup = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCY/Ca8AoMeANMhFxdGXILorO/hnrtDkVofgyLHbprPZ6CED593fIrWTPreLvuCCukPQlB+VFkxvhVHwHgSX2cWzSlPq8n6ERwSneEQ0Yknxw1m4iLYQfktEyjJgR0kR+r6A9Mi6ocVnQFKmd7MLBtVdrmbakIBAHQnSz3w14k2OkCnPo3QfwcZg57ZiZF/JPYqcsWndmVFm4qcl1hQn1Fm5BRg+saB5gYD1abnRYrlfYS2Ti7whN4j6EorXNgGsz3peSoeqyILz/ilv6c0/FvFHHSwTTSiDDoF1unxruSLTuRL9sshlGasmWbLJzJBRYKsgdBEIZAVnEe9+v5ZaO0gTMVawkEIVt4oY9SYCa4cOysm/XXJdKhUn7WgSNbFbRv4O+5kSIVB02CcuiNJ0/ahqQ3jIXynr6MOAJeDxgz/KtKmIw70BzdzRZVK9cC3a9m2+vetw1fLi5ypf6NgapYdMxyuMwBED4M0BJfN6Pbcz1Ut9QjCaKmexRbZKkG0SSrxAbfsWzGfUuSyFPVuwbBm4Jaw+zRn7DMC7gbNpj36q/GKoqMb1uqp49mwNDLdh8FP/NTRSZuJUhsjKVuj5pDQBXUNwRE8w5vI8MISIO8Jv76hVGk8NtBLLGhx3N8nXVWzwzUaXY9hMOqcIhAUoX/XKX59rboXDOWPsFX4ppxqbQ==";
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
  "nasgul_authelia_config.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_nextcloud_admin_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_authelia_session_secret.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_ldap_password.age".publicKeys = [ nasgul mordor_user ];
  "nasgul_minio_root_credentials.age".publicKeys = [ nasgul mordor_user ];
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
  "nasgul_minio_credentials.age".publicKeys = [ nasgul mordor_user ];
  "cloudflare_token.age".publicKeys = [ nasgul mordor_user ];
  "cloudflare_email.age".publicKeys = [ nasgul mordor_user ];

  # Mordor
  "mordor_cache_priv_key.pem.age".publicKeys = [ mordor mordor_user ];
  "mordor_mullvad_priv_key.age".publicKeys = [ mordor mordor_user ];
}
