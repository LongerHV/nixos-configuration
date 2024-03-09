{ pkgs, ... }:

{
  plugin = pkgs.nvimPlugins.telescope;
  configFile = ./telescope.lua;
  opts.defaults.layout_config.horizontal.width = 0.9;
  extraPackages = with pkgs; [ ripgrep fd ];
  dependencies = [ pkgs.nvimPlugins.plenary ];
}
