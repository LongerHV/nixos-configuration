{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/peripherals/trackball" = {
      scroll-wheel-emulation-button = 8;
      middle-click-emulation = true;
    };
  };
}
