{ pkgs, ... }:

{
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
      gnome-music
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
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
}
