{ pkgs, ... }:
{
  clangd = { };
  nil_ls = { };
  pyright = { };
  dockerls = { };
  bashls = { };
  terraformls = { };
  gopls = { };
  tsserver = {
    init_options.tsserver.path = "${pkgs.nodePackages.typescript}/bin/tsserver";
  };
  taplo = { };
  cssls = { };
  eslint = { settings.format = false; };
  jsonls = { init_options.provideFormatter = false; };
  html = { init_options.provideFormatter = false; };
  lua_ls = {
    settings.Lua.telemetry.enable = false;
  };
}
