{ pkgs, ... }:

{
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
  templ = { };
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
  efm =
    let
      prettier = {
        formatCommand = "prettier --stdin-filepath \${INPUT}";
        formatStdin = true;
      };
      languages = {
        python = [
          {
            formatCommand = "black --quiet -";
            formatStdin = true;
          }
          {
            formatCommand = "isort --quiet -";
            formatStdin = true;
          }
          {
            lintCommand = "pylama --from-stdin \${INPUT}";
            lintStdin = true;
            lintFormats = [ "%f:%l:%c %m" ];
          }
        ];
        go = [
          {
            lintCommand = "golangci-lint run --fix=false --out-format=line-number \${INPUT}";
            lintStdin = false;
            lintFormats = ["%f:%l: %m"];
          }
        ];
        json = [ prettier ];
        javascript = [ prettier ];
        html = [ prettier ];
        css = [ prettier ];
        vue = [ prettier ];
        markdown = [
          {
            lintCommand = "markdownlint --stdin";
            lintStdin = true;
            lintFormats = [ "%f:%l %m" "%f:%l:%c %m" "%f: %l: %m" ];
          }
          prettier
        ];
      };
    in
    {
      init_options.documentFormatting = true;
      settings = { inherit languages; };
      filetypes = builtins.attrNames languages;
    };
}
