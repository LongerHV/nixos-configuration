{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.neovim;
in
{
  options.myHome.neovim = with lib; {
    enable = mkEnableOption "neovim";
    enableLSP = mkEnableOption "enableLSP";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "${config.home.profileDirectory}/bin/nvim";
    };

    programs.neovim = lib.mkMerge [
      {
        enable = true;
        package = pkgs.unstable.neovim-unwrapped;
        vimAlias = true;
        viAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = false;
        extraConfig = ''
          let mapleader=" "

          lua <<EOF
          require("config.general")
          require("config.remaps")
          EOF
        '';
        plugins = with pkgs.nvimPlugins; [
          {
            plugin = pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars;
            type = "lua";
            config = ''

              require("config.treesitter")
          '';
          }
          nvim-treesitter-textobjects
          nvim-ts-rainbow
          {
            plugin = telescope;
            type = "lua";
            config = ''
              require("config.telescope")
            '';
          }
          telescope-file-browser
          plenary
          {
            plugin = nvim-tree;
            type = "lua";
            config = ''
              require("config.tree")
            '';
          }
          nvim-web-devicons
          {
            plugin = which-key;
            type = "lua";
            config = ''
              vim.api.nvim_set_option("timeoutlen", 300)
              require("which-key").setup({})
            '';
          }
          {
            plugin = Comment;
            type = "lua";
            config = ''
              require("config.comment")
            '';
          }
          vim-surround
          vim-repeat
          {
            plugin = gitsigns;
            type = "lua";
            config = ''
              require("gitsigns").setup()
            '';
          }
          {
            plugin = dashboard-nvim;
            type = "lua";
            config = ''
              require("config.dashboard")
            '';
          }
          {
            plugin = oceanic-next;
            type = "lua";
            config = ''
              require("config.theme")
            '';
          }
          {
            plugin = indent-blankline;
            type = "lua";
            config = ''
              require("config.blankline")
            '';
          }
          lualine
          nvim-navic
          {
            plugin = nvim-colorizer;
            type = "lua";
            config = ''
              require("colorizer").setup()
            '';
          }
          {
            plugin = dressing;
            type = "lua";
            config = ''
              require("dressing").setup()
            '';
          }
          popup
        ];
        extraPackages = with pkgs; [
          # Essentials
          nodePackages.npm
          nodePackages.neovim

          # Telescope dependencies
          ripgrep
          fd
        ];
      }

      (lib.mkIf cfg.enableLSP {
        plugins = with pkgs.nvimPlugins; [
          (
            let
              lspServers = pkgs.writeText "lsp_servers.json" (builtins.toJSON (import ./lsp_servers.nix { inherit pkgs; }));
            in
            {
              plugin = nvim-lspconfig;
              type = "lua";
              config = ''
                require("config.lsp").setup_servers("${lspServers}")
                require("config.lsp_cmp")
              '';
            }
          )
          lsp_signature
          nvim-code-action-menu
          {
            plugin = yaml-companion;
            type = "lua";
            config = ''
              require("telescope").load_extension("yaml_schema")
              local cfg = require("yaml-companion").setup({})
              require("lspconfig")["yamlls"].setup(cfg)
            '';
          }
          pkgs.unstable.vimPlugins.copilot-lua
          pkgs.unstable.vimPlugins.copilot-cmp
          {
            plugin = nvim-cmp;
            type = "lua";
            config = ''
              require("config.lsp_cmp")
            '';
          }
          cmp-path
          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp_luasnip
          nvim-autopairs
          {
            plugin = LuaSnip;
            type = "lua";
            config = ''
              require("config.snippets")
            '';
          }
          friendly-snippets
          lspkind-nvim
          {
            plugin = null-ls;
            type = "lua";
            config = ''
              require("config.language")
            '';
          }
          {
            plugin = nvim-dap;
            type = "lua";
            config = ''
              require("config.debug")
            '';
          }
          nvim-dap-ui
          nvim-dap-go
          nvim-dap-python
          {
            plugin = refactoring;
            type = "lua";
            config = ''
              require("config.refactoring")
            '';
          }
        ];
        extraPackages = with pkgs; [
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
          unstable.lua-language-server
          selene

          # Nix
          statix
          nixpkgs-fmt
          unstable.nil

          # C, C++
          clang-tools
          cppcheck

          # Shell scripting
          shfmt
          shellcheck
          shellharden

          # JavaScript
          nodePackages.prettier
          nodePackages.eslint
          nodePackages.typescript-language-server

          # Go
          go
          gopls
          golangci-lint
          delve

          # Additional
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.vscode-langservers-extracted
          nodePackages.markdownlint-cli
          taplo-cli
          codespell
          gitlint
          terraform-ls
          actionlint
        ];
      })
    ];

    xdg.configFile.nvim = {
      recursive = true;
      source = ../../../../dotfiles/nvim;
    };
  };
}
