{ config, pkgs, lib, ... }:

let
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
      picture-uri = "file://${pkgs.nierWallpaper}";
      picture-uri-dark = "file://${pkgs.nierWallpaper}";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${pkgs.nierWallpaper}";
    };
    "org/gnome/terminal/legacy" = {
      theme-variant = "dark";
    };
    "org/gnome/terminal/legacy/profiles:" = {
      default = profileUUID;
      list = [ profileUUID ];
    };
    "org/gnome/terminal/legacy/profiles:/:${profileUUID}" = {
      visible-name = "Oceanic Next";
      audible-bell = false;
      font = "Hack Nerd Font 14";
      use-system-font = false;
      use-theme-colors = false;
      background-color = colors.primary.background;
      foreground-color = colors.primary.foreground;
      bold-color = colors.primary.foreground;
      bold-color-same-as-fg = true;
      inherit (colors) palette;
      use-transparent-background = true;
      background-transparency-percent = 10;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      # night-light-temperature = 3000; # Not working
      night-light-schedule-automatic = false;
      night-light-schedule-from = 0.0;
      night-light-schedule-to = 0.0;
    };
  };
}
