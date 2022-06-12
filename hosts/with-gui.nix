{ pkgs, lib, ... }:

let
  # Apply transparency patch to gnome-terminal and pin it to specific version
  gnome-terminal-patch = builtins.fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/transparency.patch?h=gnome-terminal-transparency";
    sha256 = "0hjfyl34s9c5b1ns4yfsrl9gc86gddapap0p56hfg9200xp3ap89";
  };
  gnome-terminal-transparency = pkgs.gnome.gnome-terminal.overrideAttrs (attrs: rec {
    pname = "gnome-terminal";
    version = "3.44.1";
    src = builtins.fetchTarball {
      url = "https://download.gnome.org/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
      sha256 = "1fzl398gc9vw3072jg5f4vcgxisfh9yg52fgqd9m77g4gf582s3x";
    };
    patches = [ gnome-terminal-patch ];
  });
in
{
  environment = {
    systemPackages = with pkgs; [
      firefox
      wl-clipboard
      spotify
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnome-terminal-transparency
    ];
    gnome.excludePackages = with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      pkgs.gnome-console
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
  services.dbus.packages = [ gnome-terminal-transparency ];
  systemd.packages = [ gnome-terminal-transparency ];
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
}
