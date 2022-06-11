{ pkgs, ... }:

let
  myFont = "Hack Nerd Font";
  colors = import ./colors.nix;
in
{
  imports = [ ./fonts.nix ];

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        padding = { x = 6; y = 6; };
        opacity = 0.85;
      };
      scrolling.history = 5000;
      font = {
        normal = {
          family = myFont;
          style = "Regular";
        };
        italic = {
          family = myFont;
          style = "Italic";
        };
        bold = {
          family = myFont;
          style = "Bold";
        };
        bold_italic = {
          family = myFont;
          style = "Bold Italic";
        };
        size = 14.0;
        offset = { x = 1; y = 1; };
      };
      colors = colors.alacritty_colors;
    };
  };
}
