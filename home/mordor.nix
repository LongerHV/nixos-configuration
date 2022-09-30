{ pkgs, ... }:

{
  imports = [
    ./default.nix
    ./config/gui-packages.nix
    ./config/printing.nix
  ];

  home.packages = with pkgs; [
    reaper
  ] ++ (with pkgs.unstable; [
    qmk
    protonup
  ]);

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
