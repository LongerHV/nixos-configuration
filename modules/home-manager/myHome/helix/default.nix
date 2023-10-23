{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.helix;
in
{
  imports = [ ./lsp ];
  options.myHome.helix = with lib; {
    enable = mkEnableOption "helix";
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = pkgs.helix.override {
        makeWrapperArgs = [ ''--suffix PATH : ${lib.makeBinPath cfg.extraPackages}'' ];
      };
      settings = {
        theme = "nightfox";
        editor = {
          line-number = "relative";
          cursorline = true;
          indent-guides.render = true;
          color-modes = true;
          rulers = [ 80 ];
          cursor-shape.insert = "bar";
        };
        keys.normal = {
          Z.Z = ":wq";
          V = [ "ensure_selections_forward" "extend_to_line_end" ];
          G = "goto_last_line";
          "^" = "goto_first_nonwhitespace";
          "0" = "goto_line_start";
          "$" = "goto_line_end";
          "A-u" = "switch_to_lowercase";
          "A-U" = "switch_to_uppercase";
          "C-f" = ":format";
        };
      };
    };
  };
}
