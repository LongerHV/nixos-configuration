{ config, lib, ... }:

let
  cfg = config.homelab.homepage;
  homepage = config.services.homepage-dashboard;
in
{
  options.homelab.homepage = with lib; {
    enable = mkEnableOption "homepage";
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
    services = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
    };
    widgets = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
    };
    bookmarks = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.traefik = {
      enable = true;
      services.homepage.port = homepage.listenPort;
    };
    services.homepage-dashboard = {
      enable = true;
      inherit (cfg) services bookmarks widgets settings;
    };
  };
}
