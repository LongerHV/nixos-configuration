{ pkgs, ... }:

{
  plugin = pkgs.nvimPlugins.telescope;
  configFile = ./telescope.lua;
  extraPackages = with pkgs; [ ripgrep fd ];
  dependencies = [ pkgs.nvimPlugins.plenary ];
}
