{ config, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "${config.home.profileDirectory}/bin/nvim";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly.overrideAttrs (_: { CFLAGS = "-O3"; });
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    extraConfig = ''
      let mapleader=" "

      lua <<EOF
        require("config.general")
        require("config.snippets")
        require("config.lsp")
        require("config.lsp_cmp")
        require("config.language")
        require("config.tree")
        require("config.treesitter")
        require("config.blankline")
        require("config.debug")
        require("config.comment")
        require("config.dashboard")
        require("config.telescope")
        require("config.theme")
        require("config.refactoring")
        require("config.remaps")

        -- yaml companion
        require("telescope").load_extension("yaml_schema")
        local cfg = require("yaml-companion").setup({})
        require("lspconfig")["yamlls"].setup(cfg)

        -- which-key
        vim.api.nvim_set_option("timeoutlen", 300)
        require("which-key").setup({})

        -- gitsigns
        require("gitsigns").setup()
      EOF
    '';
    plugins = (with pkgs.unstable.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ]) ++ (with pkgs.nvimPlugins; [
      nvim-cmp
      nvim-lspconfig
      cmp-path
      cmp-buffer
      cmp-nvim-lsp
      cmp-nvim-lua
      lsp_signature
      nvim-lsp-installer
      cmp_luasnip
      LuaSnip
      friendly-snippets
      lspkind-nvim
      nvim-code-action-menu
      null-ls
      plenary
      yaml-companion
      nvim-tree
      nvim-web-devicons
      nvim-treesitter-textobjects
      nvim-ts-rainbow
      nvim-dap
      nvim-dap-go
      nvim-dap-python
      which-key
      nvim-dap-ui
      Comment
      vim-surround
      vim-repeat
      nvim-autopairs
      gitsigns
      dashboard-nvim
      oceanic-next
      indent-blankline
      lualine
      nvim-navic
      nvim-colorizer
      dressing
      telescope
      popup
      telescope-file-browser
      refactoring
    ]);
    extraPackages = with pkgs; [
      # Essentials
      nodePackages.npm
      nodePackages.neovim

      # Python
      (python3.withPackages (ps: with ps; [
        setuptools # Required by pylama for some reason
        pylama
        black
        isort
        yamllint
        debugpy
      ]))
      nodePackages.pyright

      # Lua
      sumneko-lua-language-server
      selene

      # Nix
      statix
      nixpkgs-fmt
      nil

      # C, C++
      clang-tools
      cppcheck

      # Shell scripting
      shfmt
      shellcheck
      shellharden

      # JavaScript (tsserver is not working)
      nodePackages.prettier
      nodePackages.eslint
      # nodePackages.typescript
      # nodePackages.typescript-language-server

      # Go
      go
      gopls
      golangci-lint
      delve

      # Additional
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-json-languageserver
      nodePackages.markdownlint-cli
      taplo-cli
      texlab
      codespell
      gitlint
      terraform-ls

      # Telescope dependencies
      ripgrep
      fd
    ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ../../dotfiles/nvim;
    };
  };
}
