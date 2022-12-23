{ lib, ... }:

{
  options.homelab.authelia = with lib; {
    enable = mkEnableOption "authelia";
  };
}
