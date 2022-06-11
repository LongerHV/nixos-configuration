{ pkgs, ... }:

let
  nierWallpaper = builtins.fetchurl {
    url = "https://images6.alphacoders.com/655/655990.jpg";
    sha256 = "b09b411a9c7fc7dc5be312ca9e4e4b8ee354358daa792381f207c9f4946d95fe";
  };
  profileUUID = "9e6bced8-89d4-4c52-aead-bbd59cbaad09";
  colors = import ./colors.nix;
in
{
  imports = [ ./fonts.nix ];

  dconf.settings = {
    "org/gnome/desktop/peripherals/trackball" = {
      scroll-wheel-emulation-button = 8;
      middle-click-emulation = true;
    };
    "org/gnome/desktop/sound".event-sounds = false;
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      monospace-font-name = "Hack Nerd Font";
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${nierWallpaper}";
      picture-uri-dark = "file://${nierWallpaper}";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${nierWallpaper}";
    };
    "org/gnome/terminal/legacy/profiles:" = {
      default = profileUUID;
      list = [ profileUUID ];
    };
    "org/gnome/terminal/legacy/profiles:/:${profileUUID}" = {
      visible-name = "Oceanic Next";
      font = "Hack Nerd Font 14";
      use-system-font = false;
      use-theme-colors = false;
      background-color = colors.primary.background;
      foreground-color = colors.primary.foreground;
      bold-color = colors.primary.foreground;
      bold-color-same-as-fg = true;
      inherit (colors) palette;
    };
  };
}
