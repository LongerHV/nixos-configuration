{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.gnome;
in
{
  options.mySystem.gnome = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        firefox
        wl-clipboard
        spotify
        gnomeExtensions.appindicator
        gnomeExtensions.gsconnect
      ];
      gnome.excludePackages = with pkgs; [
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        gnome-console
        gnome-connections
        gnome-contacts
        gnome-maps
        gnome-music
        gnome-weather
      ];
    };

    services = {
      xserver = {
        enable = true;
        xkb.layout = "pl";
        displayManager.gdm = {
          enable = true;
          settings = {
            greeter.IncludeAll = true;
          };
        };
        desktopManager.gnome.enable = true;
      };
      udev.packages = [ pkgs.gnome-settings-daemon ];
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    programs = {
      gnome-terminal.enable = true;
      zsh.vteIntegration = true;
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };
  };
}
