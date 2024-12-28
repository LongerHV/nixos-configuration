{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.gnome;
  profileUUID = "9e6bced8-89d4-4c52-aead-bbd59cbaad09";
  inherit (config.myHome) colors;
in
{
  imports = [ ./terminal.nix ];
  options.myHome.gnome = with lib; {
    enable = mkEnableOption "gnome";
    wallpaper = mkOption {
      type = types.package;
      default = pkgs.nierWallpaper;
    };
    font = {
      package = mkOption {
        type = types.package;
        # default = pkgs.nerd-fonts.hack; # After 25.05
        default = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
      };
      name = mkOption {
        type = types.str;
        default = "Hack Nerd Font";
      };
      size = mkOption {
        type = types.int;
        default = 14;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [ cfg.font.package ];
    dconf.settings = {
      "org/gnome/desktop/peripherals/trackball" = {
        scroll-wheel-emulation-button = 8;
        middle-click-emulation = true;
      };
      "org/gnome/desktop/sound".event-sounds = false;
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        monospace-font-name = cfg.font.name;
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file://${cfg.wallpaper}";
        picture-uri-dark = "file://${cfg.wallpaper}";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${cfg.wallpaper}";
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
        font = "${cfg.font.name} ${builtins.toString cfg.font.size}";
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
        night-light-temperature = "uint32 3000";
        night-light-schedule-automatic = false;
        night-light-schedule-from = 0.0;
        night-light-schedule-to = 0.0;
      };
      "org/gnome/mutter" = {
        workspaces-only-on-primary = true;
        dynamic-workspaces = true;
        edge-tiling = true;
      };
    };
  };
}
