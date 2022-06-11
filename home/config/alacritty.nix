{ pkgs, ... }:

let
  myFont = "Hack Nerd Font";
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
      colors = {
        primary = {
          background = "#1b2b34";
          foreground = "#d8dee9";
        };
        cursor = {
          text = "#1b2b34";
          cursor = "#ffffff";
        };
        normal = {
          black = "#343d46";
          red = "#EC5f67";
          green = "#99C794";
          yellow = "#FAC863";
          blue = "#6699cc";
          magenta = "#c594c5";
          cyan = "#5fb3b3";
          white = "#d8dee9";
        };
        bright = {
          black = "#343d46";
          red = "#EC5f67";
          green = "#99C794";
          yellow = "#FAC863";
          blue = "#6699cc";
          magenta = "#c594c5";
          cyan = "#5fb3b3";
          white = "#d8dee9";
        };
      };
    };
  };
}
