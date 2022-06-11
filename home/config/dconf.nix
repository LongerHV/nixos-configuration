{ pkgs, ... }:

let
  nierWallpaper = builtins.fetchurl {
    url = "https://images6.alphacoders.com/655/655990.jpg";
    sha256 = "b09b411a9c7fc7dc5be312ca9e4e4b8ee354358daa792381f207c9f4946d95fe";
  };
in
{
  dconf.settings = {
    "org/gnome/desktop/peripherals/trackball" = {
      scroll-wheel-emulation-button = 8;
      middle-click-emulation = true;
    };
    "org/gnome/desktop/sound".event-sounds = false;
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${nierWallpaper}";
      picture-uri-dark = "file://${nierWallpaper}";
      };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${nierWallpaper}";
      };
  };
}
