{ pkgs, config, lib, ... }:

let
  cfg = config.myHome.music-production;
in
{
  options.myHome.music-production.enable = lib.mkEnableOption "music-production";
  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        PIPEWIRE_LATENCY = "256/48000";
      };
      packages = with pkgs; [
        ardour
        reaper
      ];
      file = {
        ".lv2/Odin2.lv2".source = "${pkgs.odin2}/lib/lv2/Odin2.lv2";
        ".lv2/calf.lv2".source = "${pkgs.calf}/lib/lv2/calf.lv2";
        ".lv2/helm.lv2".source = "${pkgs.helm}/lib/lv2/helm.lv2";
        ".lv2/lsp-plugins.lv2".source = "${pkgs.lsp-plugins}/lib/lv2/lsp-plugins.lv2";
        ".vst3/Dexed.vst3".source = "${pkgs.dexed}/lib/vst3/Dexed.vst3";
        ".vst3/Vital.vst3".source = "${pkgs.vital}/lib/vst3/Vital.vst3";
      };
    };
  };
}
