{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ollama;
in
{
  options.programs.ollama = with lib; {
    enable = mkEnableOption "ollama";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.ollama = {
      description = "";
      startLimitBurst = 5;
      startLimitIntervalSec = 500;
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.steam-run}/bin/steam-run ${pkgs.ollama-bin}/bin/ollama serve";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
