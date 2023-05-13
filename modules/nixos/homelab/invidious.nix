{ config, lib, ... }:

let
  cfg = config.homelab.invidious;
in
{
  options.homelab.invidious = with lib; {
    enable = mkEnableOption "invidious";
  };

  config = lib.mkIf cfg.enable {
    homelab = {
      traefik = {
        enable = true;
        services.yt.port = config.services.invidious.port;
      };
    };
    services.invidious = {
      enable = true;
      port = lib.mkDefault 3333;
      domain = lib.mkDefault "yt.${config.homelab.domain}";
    };
  };
}
