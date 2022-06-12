_:

{
  nix.settings = {
    substituters = [
      "http://cache.nasgul.lan"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nasgul.lan:FUbOzphWIam7vHObbpGRlIdsYdM6MoHp56lfDyfUK/k="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
