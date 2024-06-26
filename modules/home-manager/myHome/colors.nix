{ lib, ... }:

let
  primary = {
    background = "#1B2B34";
    foreground = "#CDD3DE";
  };
  cursor = {
    text = "#1B2B34";
    cursor = "#CDD3DE";
  };
  normal = {
    black = "#1B2B34";
    red = "#EC5F67";
    green = "#99C794";
    yellow = "#FAC863";
    blue = "#6699CC";
    magenta = "#C594C5";
    cyan = "#5FB3B3";
    white = "#D8DEE9";
  };
  bright = {
    black = "#4F5B66";
    red = "#EC5F67";
    green = "#99C794";
    yellow = "#FAC863";
    blue = "#6699CC";
    magenta = "#C594C5";
    cyan = "#5FB3B3";
    white = "#D8DEE9";
  };
  palette = [
    normal.black
    normal.red
    normal.green
    normal.yellow
    normal.blue
    normal.magenta
    normal.cyan
    normal.white
    bright.black
    bright.red
    bright.green
    bright.yellow
    bright.blue
    bright.magenta
    bright.cyan
    bright.white
  ];
in
{
  options.myHome.colors = lib.mkOption {
    default = { inherit primary cursor normal bright palette; };
    readOnly = true;
  };
}
