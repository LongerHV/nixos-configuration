{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unstable.super-slicer
    freecad
    unstable.openscad
  ];
}
