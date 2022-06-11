{ pkgs, ... }:

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
  };
}
