{ pkgs, ... }:

{
  imports = [
    ./default.nix
    ./config/gui-packages.nix
    ./config/printing.nix
  ];
}
