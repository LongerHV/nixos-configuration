{ config, lib, pkgs, options, ... }:

let
  cfg = config.homelab.multimedia;
in
{
  options.homelab.multimedia = with lib; {
    enable = mkEnableOption "multimedia";
    jellyfin.enable = mkEnableOption "jellyfin" // { default = cfg.enable; };
    sonarr.enable = mkEnableOption "sonarr" // { default = cfg.enable; };
    radarr.enable = mkEnableOption "radarr" // { default = cfg.enable; };
    prowlarr.enable = mkEnableOption "prowlarr" // { default = cfg.enable; };
    bazarr.enable = mkEnableOption "bazarr" // { default = cfg.enable; };
    deluge = {
      enable = mkEnableOption "deluge" // { default = cfg.enable; };
      interface = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config = {
    users.groups.multimedia = { };
    users.users."${config.mySystem.user}".extraGroups = [ "multimedia" ];

    systemd.tmpfiles.rules = [
      "d ${config.homelab.storage}/media 0770 - multimedia - -"
    ];

    homelab.traefik.services =
      (lib.optionalAttrs cfg.jellyfin.enable { jellyfin = { port = 8096; }; }) //
      (lib.optionalAttrs cfg.sonarr.enable { sonarr = { port = 8989; }; }) //
      (lib.optionalAttrs cfg.radarr.enable { radarr = { port = 7878; }; }) //
      (lib.optionalAttrs cfg.prowlarr.enable { prowlarr = { port = 9696; }; }) //
      (lib.optionalAttrs cfg.bazarr.enable { bazarr = { port = config.services.bazarr.listenPort; }; }) //
      (lib.optionalAttrs cfg.deluge.enable { deluge = { inherit (config.services.deluge.web) port; }; });

    services = {
      jellyfin = {
        enable = true;
        package = pkgs.unstable.jellyfin;
        group = "multimedia";
      };
      sonarr = { inherit (cfg.sonarr) enable; group = "multimedia"; };
      radarr = { inherit (cfg.radarr) enable; group = "multimedia"; };
      bazarr = { inherit (cfg.bazarr) enable; group = "multimedia"; };
      prowlarr = { inherit (cfg.prowlarr) enable; };
      deluge = {
        inherit (cfg.deluge) enable;
        group = "multimedia";
        web.enable = true;
        dataDir = "${config.homelab.storage}/media/torrent";
        declarative = true;
        config = {
          enabled_plugins = [ "Label" ];
        } // (lib.optionalAttrs (cfg.deluge.interface != null) {
          outgoing_interface = "wg1";
        });
        authFile = pkgs.writeTextFile {
          name = "deluge-auth";
          text = ''
            localclient::10
          '';
        };
      };
    };
  };
}
