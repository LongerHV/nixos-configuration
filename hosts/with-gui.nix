{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      firefox
      wl-clipboard
      spotify
    ];
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.layout = "pl";

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
