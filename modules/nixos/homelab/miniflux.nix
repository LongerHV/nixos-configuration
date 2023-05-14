{ config, lib, ... }:

let
  cfg = config.homelab.miniflux;
in
{
  options.homelab.miniflux = with lib; {
    enable = mkEnableOption "miniflux";
    port = mkOption {
      default = 8085;
      type = types.port;
    };
    adminCredentialsFile = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    homelab = {
      traefik = {
        enable = true;
        services.rss.port = cfg.port;
      };
    };
    services.miniflux = {
      enable = true;
      inherit (cfg) adminCredentialsFile;
      config = {
        LISTEN_ADDR = "localhost:${builtins.toString cfg.port}";
        BASE_URL = "https://rss.${config.homelab.domain}";
      };
    };
  };
}
