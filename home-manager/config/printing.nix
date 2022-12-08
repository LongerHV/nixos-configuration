{ pkgs, ... }:

{
  home.packages = with pkgs; [
    super-slicer-latest
    freecad
    openscad
  ];
}
