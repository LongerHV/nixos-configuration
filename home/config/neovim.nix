{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    extraConfig = ''
      let mapleader=" "

      lua <<EOF
        require("config.general")
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

        -- pounce
        vim.api.nvim_set_keymap("n", "s", "<cmd>Pounce<cr>", { noremap = true })
        vim.api.nvim_set_keymap("n", "S", "<cmd>PounceRepeat<cr>", { noremap = true })
        require("pounce").setup({
          accept_keys = "NTHDESIROAUFYW",
        })
      EOF
    '';
    plugins = with pkgs.nvimPlugins; [
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
      nvim-lightbulb
      nvim-code-action-menu
      null-ls
      plenary
      yaml-companion
      nvim-tree
      nvim-web-devicons
      (pkgs.unstable.vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.unstable.tree-sitter.allGrammars))
      nvim-treesitter-textobjects
      nvim-ts-rainbow
      nvim-treesitter-textsubjects
      nvim-dap
      which-key
      nvim-dap-ui
      Comment
      vim-surround
      vim-repeat
      nvim-autopairs
      gitsigns
      pounce
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
    ];
    extraPackages = with pkgs.unstable; [
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
      rnix-lsp

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
