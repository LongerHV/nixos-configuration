let
  inherit (import ../secrets/secrets_keys.nix)
    nasgul
    mordor
    palantir
    anarion
    isildur
    mordor_user
    backup
    ;
in
{
  "ca.key.age".publicKeys = [ mordor_user backup ];
  "mordor.key.age".publicKeys = [ mordor ];
  "nasgul.key.age".publicKeys = [ nasgul ];
  "palantir.key.age".publicKeys = [ palantir ];
  "anarion.key.age".publicKeys = [ anarion ];
  "isildur.key.age".publicKeys = [ isildur ];
}
