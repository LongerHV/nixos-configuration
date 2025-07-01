{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.embedded;
in
{
  options.mySystem.embedded = with lib; {
    enable = mkEnableOption "embedded";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    services.udev.packages = with pkgs; [ openocd ];
  };
}
