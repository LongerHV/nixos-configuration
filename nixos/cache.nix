_:

{
  nix.settings = {
    substituters = [
      "https://cache.local.longerhv.xyz"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.local.longerhv.xyz:ioE/YEOpla3uyof/kZQG+gNKgeBAhOMWh+riRAEzKDA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
