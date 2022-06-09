{ pkgs, ... }:

{
  imports = [
    ./default.nix
    ./config/gui-packages.nix
    ./config/dconf.nix
    ./config/printing.nix
  ];
}
