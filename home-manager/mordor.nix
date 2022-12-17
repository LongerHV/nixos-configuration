{ pkgs, ... }:

{
  imports = [
    ./default.nix
    ./config/gui-packages.nix
    ./config/printing.nix
  ];

  home.packages = with pkgs; [
    reaper
    qmk
    protonup
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
