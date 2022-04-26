{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neofetch
  ];
}
