{ config, lib, pkgs, options, ... }:

let
  hl = config.homelab;
  cfg = hl.multimedia;
in
{
  options.homelab.multimedia = with lib; {
    enable = mkEnableOption "multimedia";
    jellyfin.enable = mkEnableOption "jellyfin";
    arr.enable = mkEnableOption "arr";
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

    homelab.traefik.services = lib.mkIf hl.traefik.enable (lib.mkMerge [
      (lib.optionalAttrs cfg.jellyfin.enable { jellyfin = { port = 8096; }; })
      (lib.optionalAttrs cfg.arr.enable {
        sonarr = { port = 8989; authelia = true; };
        radarr = { port = 7878; authelia = true; };
        prowlarr = { port = 9696; authelia = true; };
        bazarr = { port = config.services.bazarr.listenPort; authelia = true; };
      })
      (lib.optionalAttrs cfg.deluge.enable { deluge = { inherit (config.services.deluge.web) port; authelia = true; }; })
    ]);

    services = {
      jellyfin = {
        inherit (cfg.jellyfin) enable;
        group = "multimedia";
      };
      sonarr = { inherit (cfg.arr) enable; group = "multimedia"; };
      radarr = { inherit (cfg.arr) enable; group = "multimedia"; };
      bazarr = { inherit (cfg.arr) enable; group = "multimedia"; };
      prowlarr = { inherit (cfg.arr) enable; };
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
