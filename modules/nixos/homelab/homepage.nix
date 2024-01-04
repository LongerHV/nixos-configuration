{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.homepage;
  homepage = config.services.homepage-dashboard;
  format = pkgs.formats.yaml { };
  configDir = "/var/lib/homepage-dashboard";
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
    services.homepage-dashboard.enable = true;
    systemd.services.homepage-dashboard = {
      preStart = ''
        ln -sf ${format.generate "settings.yaml" cfg.settings} ${configDir}/settings.yaml
        ln -sf ${format.generate "services.yaml" cfg.services} ${configDir}/services.yaml
        ln -sf ${format.generate "widgets.yaml" cfg.widgets} ${configDir}/widgets.yaml
        ln -sf ${format.generate "bookmarks.yaml" cfg.bookmarks} ${configDir}/bookmarks.yaml
      '';
    };
  };
}
