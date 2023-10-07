{ pkgs, ... }:

{
  clangd = { };
  nil_ls = {
    settings.nil = {
      nix.flake.autoEvalInputs = true;
      formatting.command = [ "nixpkgs-fmt" ];
    };
  };
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
  volar.init_options.typescript.tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
  lua_ls = {
    settings.Lua = {
      runtime.version = "LuaJIT";
      diagnostics.globals = [ "vim" ];
      workspace.library = { };
      telemetry.enable = false;
    };
  };
}
