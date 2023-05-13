{ config, lib, ... }:

let
  cfg = config.homelab.invidious;
  hasTLS = config.homelab.traefik.cloudflareTLS.enable;
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
      settings = {
        https_only = hasTLS;
        external_port = if hasTLS then 443 else 80;
        default_user_preferences = {
          locale = "pl";
          region = "PL";
          captions = [ "Polish" "English" "Englich (auto-generated)" ];
          feed_menu = [ "Subscriptions" "Playlists" ];
          default_home = "Subscriptions";
          player_style = "youtube";
          quality = "dash";
        };
      };
    };
  };
}
