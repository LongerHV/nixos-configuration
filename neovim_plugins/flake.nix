{
  description = "Neovim plugin overlay";
  inputs = {
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-nvim-lua = {
      url = "github:hrsh7th/cmp-nvim-lua";
      flake = false;
    };
    lsp_signature = {
      url = "github:ray-x/lsp_signature.nvim";
      flake = false;
    };
    nvim-lsp-installer = {
      url = "github:williamboman/nvim-lsp-installer";
      flake = false;
    };
    cmp_luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    LuaSnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    friendly-snippets = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    lspkind-nvim = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };
    nvim-lightbulb = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };
    nvim-code-action-menu = {
      url = "github:weilbith/nvim-code-action-menu";
      flake = false;
    };
    null-ls = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    plenary = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    yaml-companion = {
      url = "github:someone-stole-my-name/yaml-companion.nvim";
      flake = false;
    };
    nvim-tree = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    nvim-ts-rainbow = {
      url = "github:p00f/nvim-ts-rainbow";
      flake = false;
    };
    nvim-treesitter-textsubjects = {
      url = "github:RRethy/nvim-treesitter-textsubjects";
      flake = false;
    };
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    Comment = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    vim-surround = {
      url = "github:tpope/vim-surround";
      flake = false;
    };
    vim-repeat = {
      url = "github:tpope/vim-repeat";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    pounce = {
      url = "github:rlane/pounce.nvim";
      flake = false;
    };
    dashboard-nvim = {
      url = "github:glepnir/dashboard-nvim";
      flake = false;
    };
    oceanic-next = {
      url = "github:LongerHV/oceanic-next";
      flake = false;
    };
    indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    lualine = {
      url = "github:hoob3rt/lualine.nvim";
      flake = false;
    };
    nvim-navic = {
      url = "github:SmiteshP/nvim-navic";
      flake = false;
    };
    nvim-colorizer = {
      url = "github:norcalli/nvim-colorizer.lua";
      flake = false;
    };
    dressing = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };
    telescope = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    popup = {
      url = "github:nvim-lua/popup.nvim";
      flake = false;
    };
    telescope-file-browser = {
      url = "github:nvim-telescope/telescope-file-browser.nvim";
      flake = false;
    };
  };
  outputs =
    inputs@{ self
    , nixpkgs
    , nvim-cmp
    , nvim-lspconfig
    , cmp-path
    , cmp-buffer
    , cmp-nvim-lsp
    , cmp-nvim-lua
    , lsp_signature
    , nvim-lsp-installer
    , cmp_luasnip
    , LuaSnip
    , friendly-snippets
    , lspkind-nvim
    , nvim-lightbulb
    , nvim-code-action-menu
    , null-ls
    , plenary
    , yaml-companion
    , nvim-tree
    , nvim-web-devicons
    , nvim-treesitter
    , nvim-treesitter-textobjects
    , nvim-ts-rainbow
    , nvim-treesitter-textsubjects
    , nvim-dap
    , which-key
    , nvim-dap-ui
    , Comment
    , vim-surround
    , vim-repeat
    , nvim-autopairs
    , gitsigns
    , pounce
    , dashboard-nvim
    , oceanic-next
    , indent-blankline
    , lualine
    , nvim-navic
    , nvim-colorizer
    , dressing
    , telescope
    , popup
    , telescope-file-browser
    }: {
      overlay = final: prev: {
        nvimPlugins = {
          nvim-cmp = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-cmp";
            version = src.lastModifiedDate;
            src = nvim-cmp;
          };
          nvim-lspconfig = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-lspconfig";
            version = src.lastModifiedDate;
            src = nvim-lspconfig;
          };
          cmp-path = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "cmp-path";
            version = src.lastModifiedDate;
            src = cmp-path;
          };
          cmp-buffer = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "cmp-buffer";
            version = src.lastModifiedDate;
            src = cmp-buffer;
          };
          cmp-nvim-lsp = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "cmp-nvim-lsp";
            version = src.lastModifiedDate;
            src = cmp-nvim-lsp;
          };
          cmp-nvim-lua = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "cmp-nvim-lua";
            version = src.lastModifiedDate;
            src = cmp-nvim-lua;
          };
          lsp_signature = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "lsp_signature";
            version = src.lastModifiedDate;
            src = lsp_signature;
          };
          nvim-lsp-installer = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-lsp-installer";
            version = src.lastModifiedDate;
            src = nvim-lsp-installer;
          };
          cmp_luasnip = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "cmp_luasnip";
            version = src.lastModifiedDate;
            src = cmp_luasnip;
          };
          LuaSnip = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "LuaSnip";
            version = src.lastModifiedDate;
            src = LuaSnip;
          };
          friendly-snippets = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "friendly-snippets";
            version = src.lastModifiedDate;
            src = friendly-snippets;
          };
          lspkind-nvim = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "lspkind-nvim";
            version = src.lastModifiedDate;
            src = lspkind-nvim;
          };
          nvim-lightbulb = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-lightbulb";
            version = src.lastModifiedDate;
            src = nvim-lightbulb;
          };
          nvim-code-action-menu = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-code-action-menu";
            version = src.lastModifiedDate;
            src = nvim-code-action-menu;
          };
          null-ls = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "null-ls";
            version = src.lastModifiedDate;
            src = null-ls;
          };
          plenary = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "plenary";
            version = src.lastModifiedDate;
            src = plenary;
          };
          yaml-companion = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "yaml-companion";
            version = src.lastModifiedDate;
            src = yaml-companion;
          };
          nvim-tree = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-tree";
            version = src.lastModifiedDate;
            src = nvim-tree;
          };
          nvim-web-devicons = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-web-devicons";
            version = src.lastModifiedDate;
            src = nvim-web-devicons;
          };
          nvim-treesitter = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-treesitter";
            version = src.lastModifiedDate;
            src = nvim-treesitter;
          };
          nvim-treesitter-textobjects = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-treesitter-textobjects";
            version = src.lastModifiedDate;
            src = nvim-treesitter-textobjects;
          };
          nvim-ts-rainbow = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-ts-rainbow";
            version = src.lastModifiedDate;
            src = nvim-ts-rainbow;
          };
          nvim-treesitter-textsubjects = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-treesitter-textsubjects";
            version = src.lastModifiedDate;
            src = nvim-treesitter-textsubjects;
          };
          nvim-dap = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-dap";
            version = src.lastModifiedDate;
            src = nvim-dap;
          };
          which-key = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "which-key";
            version = src.lastModifiedDate;
            src = which-key;
          };
          nvim-dap-ui = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-dap-ui";
            version = src.lastModifiedDate;
            src = nvim-dap-ui;
          };
          Comment = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "Comment";
            version = src.lastModifiedDate;
            src = Comment;
          };
          vim-surround = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "vim-surround";
            version = src.lastModifiedDate;
            src = vim-surround;
          };
          vim-repeat = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "vim-repeat";
            version = src.lastModifiedDate;
            src = vim-repeat;
          };
          nvim-autopairs = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-autopairs";
            version = src.lastModifiedDate;
            src = nvim-autopairs;
          };
          gitsigns = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "gitsigns";
            version = src.lastModifiedDate;
            src = gitsigns;
          };
          pounce = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "pounce";
            version = src.lastModifiedDate;
            src = pounce;
          };
          dashboard-nvim = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "dashboard-nvim";
            version = src.lastModifiedDate;
            src = dashboard-nvim;
          };
          oceanic-next = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "oceanic-next";
            version = src.lastModifiedDate;
            src = oceanic-next;
          };
          indent-blankline = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "indent-blankline";
            version = src.lastModifiedDate;
            src = indent-blankline;
          };
          lualine = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "lualine";
            version = src.lastModifiedDate;
            src = lualine;
          };
          nvim-navic = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-navic";
            version = src.lastModifiedDate;
            src = nvim-navic;
          };
          nvim-colorizer = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "nvim-colorizer";
            version = src.lastModifiedDate;
            src = nvim-colorizer;
          };
          dressing = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "dressing";
            version = src.lastModifiedDate;
            src = dressing;
          };
          telescope = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "telescope";
            version = src.lastModifiedDate;
            src = telescope;
          };
          popup = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "popup";
            version = src.lastModifiedDate;
            src = popup;
          };
          telescope-file-browser = prev.pkgs.vimUtils.buildNeovimPluginFrom2Nix rec {
            pname = "telescope-file-browser";
            version = src.lastModifiedDate;
            src = telescope-file-browser;
          };
        };
      };
    };
}
