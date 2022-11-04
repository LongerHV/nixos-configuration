{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unstable.super-slicer-latest
    freecad
    unstable.openscad
  ];
}
