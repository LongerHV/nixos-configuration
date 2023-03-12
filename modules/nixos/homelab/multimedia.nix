{ config, lib, pkgs, options, ... }:

let
  hl = config.homelab;
  cfg = hl.multimedia;
in
{
  options.homelab.multimedia = with lib; {
    enable = mkEnableOption "multimedia";
    deluge = {
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

    homelab.traefik = {
      enable = true;
      services = {
        jellyfin.port = 8096;
        sonarr.port = 8989;
        radarr.port = 7878;
        prowlarr.port = 9696;
        bazarr.port = config.services.bazarr.listenPort;
        deluge.port = config.services.deluge.web.port;
      };

    };

    services = {
      jellyfin = {
        enable = true;
        group = "multimedia";
      };
      sonarr = { enable = true; group = "multimedia"; };
      radarr = { enable = true; group = "multimedia"; };
      bazarr = { enable = true; group = "multimedia"; };
      prowlarr = { enable = true; };
      deluge = {
        enable = true;
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
