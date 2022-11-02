{ config, lib, pkgs, ... }:

let
  colors = import ./colors.nix;
  inherit (colors.primary) foreground background;
  inherit (colors.normal) black red green yellow blue magenta cyan orange white;
  grey = colors.bright.black;
  default = "default";

  yamlFormat = pkgs.formats.yaml { };
  skin = {
    k9s = {
      body = {
        fgColor = foreground;
        bgColor = default;
        logoColor = magenta;
      };
      prompt = {
        fgColor = foreground;
        bgColor = default;
        suggestColor = orange;
      };
      info = {
        fgColor = blue;
        sectionColor = foreground;
      };
      dialog = {
        fgColor = foreground;
        bgColor = default;
        buttonFgColor = foreground;
        buttonBgColor = magenta;
        buttonFocusFgColor = background;
        buttonFocusBgColor = magenta;
        labelFgColor = orange;
        fieldFgColor = foreground;
      };
      frame = {
        border = {
          fgColor = blue;
          focusColor = cyan;
        };
        menu = {
          fgColor = white;
          keyColor = blue;
          numKeyColor = magenta;
        };
        crumbs = {
          fgColor = default;
          bgColor = cyan;
          activeColor = orange;
        };
        status = {
          newColor = cyan;
          modifyColor = magenta;
          addColor = green;
          errorColor = red;
          pendingColor = orange;
          highlightColor = blue;
          killColor = grey;
          completedColor = grey;
        };
        title = {
          fgColor = cyan;
          bgColor = default;
          highlightColor = magenta;
          counterColor = white;
          filterColor = blue;
        };
      };
      views = {
        charts = {
          bgColor = default;
          defaultDialColors = [ green orange ];
          defaultChartColors = [ green orange ];
        };
        table = {
          fgColor = blue;
          bgColor = default;
          cursorFgColor = default;
          cursorBgColor = cyan;
          markColor = default;
          header = {
            fgColor = default;
            bgColor = default;
            sorterColor = orange;
          };
        };
        xray = {
          fgColor = blue;
          bgColor = default;
          cursorColor = cyan;
          graphicColor = white;
        };
        logs = {
          bgColor = default;
          indicator = {
            bgColor = default;
          };
        };
      };
    };
  };
in
{
  # xdg.configFile."k9s/skin.yml" = {
  #   source = yamlFormat.generate "k9s-skin" skin;
  # };
}
