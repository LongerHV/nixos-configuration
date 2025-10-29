{ config, lib, ... }:

let
  cfg = config.mySystem.rtaudio;
in
{
  options.mySystem.rtaudio = {
    enable = lib.mkEnableOption "rtaudio";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [ "threadirqs" ];
      kernel.sysctl = {
        "vm.swappiness" = 10;
      };
    };
    security.rtkit.enable = true;
    users.users.${config.mySystem.user}.extraGroups = [ "audio" ];
    security.pam.loginLimits = [
      {
        domain = "@audio";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@audio";
        type = "-";
        item = "rtprio";
        value = "75";
      }
    ];
    powerManagement.cpuFreqGovernor = "performance";
    services.udev.extraRules = ''
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
    '';
  };
}
