{ config, lib, ... }:

let
  cfg = config.homelab.backups;
  default = {
    initialize = true;
    inherit (cfg) repository passwordFile environmentFile;
  };
in
{
  options.homelab.backups = with lib; {
    enable = mkEnableOption "backups";
    repository = mkOption {
      type = types.str;
    };
    passwordFile = mkOption {
      type = types.str;
    };
    environmentFile = mkOption {
      type = types.str;
    };
    services = mkOption {
      type = types.attrs;
    };
  };

  config.services.restic.backups = lib.mkIf cfg.enable (
    builtins.mapAttrs (name: settings: default // settings) cfg.services
  );
}
