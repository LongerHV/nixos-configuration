{ config, helper, lib, pkgs, options, ... }:

let
  hl = config.homelab;
  cfg = hl.multimedia;
in
{
  options.homelab.multimedia = with lib; {
    enable = mkEnableOption "multimedia";
    jellyfin.enable = mkEnableOption "jellyfin";
    sonarr.enable = mkEnableOption "sonarr";
    radarr.enable = mkEnableOption "radarr";
    prowlarr.enable = mkEnableOption "prowlarr";
    bazarr.enable = mkEnableOption "bazarr";
    deluge = {
      enable = mkEnableOption "deluge";
      interface = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.multimedia = { };
    users.users."${config.mySystem.user}".extraGroups = [ "multimedia" ];

    systemd.tmpfiles.rules = [
      "d ${config.homelab.storage}/media 0770 - multimedia - -"
    ];

    homelab.traefik.services = lib.mkIf hl.traefik.enable (helper.mergeAttrsets [
      (lib.optionalAttrs cfg.jellyfin.enable { jellyfin = { port = 8096; }; })
      (lib.optionalAttrs cfg.sonarr.enable { sonarr = { port = 8989; authelia = true; }; })
      (lib.optionalAttrs cfg.radarr.enable { radarr = { port = 7878; authelia = true; }; })
      (lib.optionalAttrs cfg.prowlarr.enable { prowlarr = { port = 9696; authelia = true; }; })
      (lib.optionalAttrs cfg.bazarr.enable { bazarr = { port = config.services.bazarr.listenPort; authelia = true; }; })
      (lib.optionalAttrs cfg.deluge.enable { deluge = { inherit (config.services.deluge.web) port; authelia = true; }; })
    ]);

    services = {
      jellyfin = {
        inherit (cfg.jellyfin) enable;
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
          outgoing_interface = cfg.deluge.interface;
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
