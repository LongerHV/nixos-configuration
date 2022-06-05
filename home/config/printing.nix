{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    super-slicer
    freecad
    openscad
  ];
}
