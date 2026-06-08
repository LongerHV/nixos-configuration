{ pkgs, ... }:

{
  plugin = pkgs.nvimPlugins.nvim-cmp;
  configFile = ./cmp.lua;
  dependencies = with pkgs.nvimPlugins; [
    cmp-nvim-lsp
    cmp-path
    cmp-buffer
    copilot-cmp
    copilot-lua
    lspkind-nvim
  ];
}
