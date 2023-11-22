{ config, lib, pkgs, ... }:

let
  cfg = config.services.ollama;
  home = "/var/lib/ollama";
in
{
  options.services.ollama = with lib; {
    enable = mkEnableOption "ollama";
  };

  config = lib.mkIf cfg.enable {
    users.users.ollama = {
      group = "ollama";
      isSystemUser = true;
      createHome = true;
      inherit home;
    };
    users.groups.ollama = { };
    systemd.services.ollama = {
      description = "Get up and running with large language models locally.";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.steam-run}/bin/steam-run ${pkgs.ollama-bin}/bin/ollama serve";
        WorkingDirectory = home;
        User = "ollama";
        Group = "ollama";
        Restart = "always";
      };
    };
  };
}
