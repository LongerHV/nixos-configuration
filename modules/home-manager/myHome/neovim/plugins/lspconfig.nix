{ pkgs, lib, ... }:

let
  lsp_servers = {
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
    marksman = { };
    tsserver = {
      init_options.tsserver.path = "${pkgs.nodePackages.typescript}/bin/tsserver";
    };
    taplo = { };
    tailwindcss = {
      init_options = {
        userLanguages = {
          heex = "html";
        };
      };
    };
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
  };
in
{
  plugin = pkgs.nvimPlugins.nvim-lspconfig;
  preConfig = /* lua */ ''
    dofile("${./lspconfig.lua}").setup_servers(vim.fn.json_decode("${lib.strings.escape ["\""] (builtins.toJSON lsp_servers)}"))
  '';
  dependencies = [
    pkgs.nvimPlugins.schemastore
  ];
  extraPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      setuptools # Required by pylama for some reason
      pylama
      black
      isort
      yamllint
    ]))
    (nodePackages.pyright.override {
      inherit (unstable.nodePackages.pyright) src version name;
    })
    unstable.lua-language-server
    unstable.nil
    unstable.gopls
    nixpkgs-fmt
    templ
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.prettier
    yaml-language-server
    terraform-ls
    tflint
    efm-langserver
    taplo
    tailwindcss-language-server
    marksman
  ];
}
