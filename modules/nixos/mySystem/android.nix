{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.android;
in
{
  options.mySystem.android = with lib; {
    enable = mkEnableOption "android";
  };

  config = lib.mkIf cfg.enable {
    users.users.${config.mySystem.user}.extraGroups = [ "adbusers" ];
    programs.adb.enable = true;
    services.udev.packages = with pkgs; [ android-udev-rules ];
  };
}
