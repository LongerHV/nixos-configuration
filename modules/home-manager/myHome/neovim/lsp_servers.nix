{ pkgs, ... }:

{
  nil_ls = {
    settings.nil = {
      nix = {
        maxMemoryMB = 4096;
        flake.autoEvalInputs = true;
      };
      formatting.command = [ "nixpkgs-fmt" ];
    };
  };
  pyright = { };
  dockerls = { };
  bashls = { };
  terraformls = { };
  tflint = { };
  gopls = { };
  templ = { };
  tsserver = {
    init_options.tsserver.path = "${pkgs.nodePackages.typescript}/bin/tsserver";
  };
  taplo = { };
  cssls = { };
  eslint = { settings.format = false; };
  jsonls = { init_options.provideFormatter = false; };
  yamlls = { };
  html = { init_options.provideFormatter = false; };
  volar.init_options.typescript.tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
  elixirls.cmd = [ "${pkgs.elixir-ls}/bin/elixir-ls" ];
  lua_ls = {
    settings.Lua = {
      runtime.version = "LuaJIT";
      diagnostics.globals = [ "vim" ];
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
        go = [
          {
            lintCommand = "golangci-lint run --fix=false --out-format=line-number \${INPUT}";
            lintStdin = false;
            lintFormats = [ "%f:%l: %m" ];
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
  efm_python = {
    init_options.documentFormatting = true;
    settings = {
      languages.python = [
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
    };
    filetypes = [ "python" ];
    root_dir = [ "pyproject.toml" "setup.cfg" "seput.py" ".git" ];
  };
}
