let
  inherit (import ../secrets/secrets_keys.nix) nasgul mordor mordor_user backup;
in
{
  "ca.key.age".publicKeys = [ mordor_user backup ];
  "mordor.key.age".publicKeys = [ mordor ];
  "nasgul.key.age".publicKeys = [ nasgul ];
}
