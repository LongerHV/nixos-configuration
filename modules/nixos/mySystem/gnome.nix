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
      gnome.excludePackages = with pkgs.gnome; [
        cheese # webcam tool
        gedit # text editor
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        pkgs.gnome-console
        pkgs.gnome-connections
        gnome-contacts
        gnome-maps
        gnome-music
        gnome-weather
      ];
    };

    services.xserver.enable = true;
    services.xserver.layout = "pl";
    services.xserver.displayManager.gdm = {
      enable = true;
      settings = {
        greeter.IncludeAll = true;
      };
    };
    services.xserver.desktopManager.gnome.enable = true;
    services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
    programs.gnome-terminal.enable = true;
    programs.zsh.vteIntegration = true;
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
