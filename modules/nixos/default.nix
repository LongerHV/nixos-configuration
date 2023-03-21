{
  mySystem = import ./mySystem;
  homelab = import ./homelab;

  authelia = import ./authelia.nix;
  dashy = import ./dashy.nix;
}
