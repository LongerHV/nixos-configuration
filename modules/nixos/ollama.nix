{ config, lib, pkgs, ... }:

let
  cfg = config.services.ollama;
  home = "/var/lib/ollama";
  fhsEnv = pkgs.buildFHSUserEnv {
    name = "ollama-fhs";
    targetPkgs = pkgs: [ ];
    multiPkgs = pkgs: [ pkgs.ollama-bin ];
    runScript = "ollama";
  };
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
        ExecStart = "${fhsEnv}/bin/ollama-fhs serve";
        WorkingDirectory = home;
        User = "ollama";
        Group = "ollama";
        Restart = "always";
      };
    };
  };
}
