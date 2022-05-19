-- Plugin specification
return require("packer").startup(function(use)
	-- LSP
	use({
		-- Autocomplete
		"hrsh7th/nvim-cmp",
		requires = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"ray-x/lsp_signature.nvim",
			"williamboman/nvim-lsp-installer",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind-nvim",
			"kosayoda/nvim-lightbulb",
			"weilbith/nvim-code-action-menu",
		},
		config = function()
			require("config.lsp")
			require("config.lsp_cmp")
			vim.cmd([[autocmd CursorHold,CursorHoldI * lua require("nvim-lightbulb").update_lightbulb()]])
			require("luasnip/loaders/from_vscode").lazy_load()
		end,
	})
	-- use 'nvim-lua/lsp_extensions.nvim'

	-- Linting and formatting
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim" },
		config = function()
			require("config.language")
		end,
	})
	use({
		"salkin-mada/openscad.nvim",
		config = function()
			require("openscad")
			vim.g.openscad_cheatsheet_toggle_key = "<leader>hc"
			vim.g.openscad_help_trig_key = "<leader>hh"
			vim.g.openscad_help_manual_trig_key = "<leader>hm"
			vim.g.openscad_exec_openscad_trig_key = "<leader>he"
			vim.g.openscad_top_toggle = "<leader>ht"
		end,
	})
	use({
		"someone-stole-my-name/yaml-companion.nvim",
		requires = {
			{ "neovim/nvim-lspconfig" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function()
			require("telescope").load_extension("yaml_schema")
			local cfg = require("yaml-companion").setup({})
			require("lspconfig")["yamlls"].setup(cfg)
		end,
	})

	-- File manager
	use({
		"kyazdani42/nvim-tree.lua",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>NvimTreeToggle<cr>", {})
			require("nvim-tree").setup({
				update_focused_file = {
					enable = true,
				},
				view = {
					width = 40,
					number = true,
					relativenumber = true,
				},
			})
		end,
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		requires = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			-- "nvim-treesitter/playground",
			"p00f/nvim-ts-rainbow",
			"RRethy/nvim-treesitter-textsubjects",
			"yioneko/nvim-yati",
		},
		run = ":TSUpdate",
		config = function()
			require("config.treesitter")
		end,
	})

	-- Debugging
	use({
		"mfussenegger/nvim-dap",
		requires = { "folke/which-key.nvim", "rcarriga/nvim-dap-ui" },
		config = function()
			require("config.debug")
		end,
	})

	-- Quality of life enhancements
	use({
		-- Use 'CTRL + /' to comment line or selection
		"numToStr/Comment.nvim",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("Comment").setup()
			vim.api.nvim_set_keymap("n", "", '<cmd>lua require("Comment.api").toggle_current_linewise()<cr>', {})
			vim.api.nvim_set_keymap(
				"x",
				"",
				'<esc><cmd>lua require("Comment.api").toggle_blockwise_op(vim.fn.visualmode())<cr>',
				{}
			)
		end,
	})
	-- Manipulate parentheses, brackets etc
	use({
		"tpope/vim-surround",
		requires = { "tpope/vim-repeat" },
	})
	-- Auto close brackets etc (with treesitter support)
	use({
		"windwp/nvim-autopairs",
		after = { "nvim-cmp" },
		config = function()
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			require("nvim-autopairs").setup({ check_ts = true })
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({}))
		end,
	})
	use({
		"folke/which-key.nvim",
		config = function()
			vim.api.nvim_set_option("timeoutlen", 300)
			require("which-key").setup({})
		end,
	})
	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	})
	use({
		"rlane/pounce.nvim",
		config = function()
			vim.api.nvim_set_keymap("n", "s", "<cmd>Pounce<cr>", { noremap = true })
			vim.api.nvim_set_keymap("n", "S", "<cmd>PounceRepeat<cr>", { noremap = true })
			require("pounce").setup({
				accept_keys = "NTHDESIROAUFYW",
			})
		end,
	})

	-- Looks
	use({
		-- Startpage
		"glepnir/dashboard-nvim",
		requires = "nvim-telescope/telescope.nvim",
		config = function()
			require("config.dashboard")
		end,
	})
	use({
		-- Color theme
		"mhartington/oceanic-next",
		config = function()
			vim.cmd("colorscheme OceanicNext")
			-- Fix transparent background
			vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
			vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")
			vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
			vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
			vim.cmd("hi WinSeparator guibg=NONE")
		end,
	})
	use({
		-- Draw indentation lines (highlighting based on treesitter)
		"lukas-reineke/indent-blankline.nvim",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("config.blankline")
		end,
	})
	use({
		-- Status line
		"hoob3rt/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "OceanicNext", globalstatus = true },
				extensions = { 'nvim-tree' },
			})
		end,
	})
	use({
		-- Color highlighter
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	})
	use({
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup({})
		end,
	})

	-- Telescope (Fuzzy finding)
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons",
			"folke/which-key.nvim",
		},
		config = function()
			require("config.telescope")
		end,
	})
end)
