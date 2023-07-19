{ config, lib, ... }:

let
  cfg = config.myHome.helix;
in
{
  imports = [ ./lsp.nix ];
  options.myHome.helix = with lib; {
    enable = mkEnableOption "helix";
  };
  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
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
          space.F = ":format";
          Z.Z = ":wq";
          V = [ "ensure_selections_forward" "extend_to_line_end" ];
          G = "goto_last_line";
          "^" = "goto_first_nonwhitespace";
          "0" = "goto_line_start";
          "$" = "goto_line_end";
        };
      };
    };
  };
}
