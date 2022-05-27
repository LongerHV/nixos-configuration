require("nvim-treesitter.configs").setup({
	ensure_installed = "all",
	indent = { enable = true, disable = { "python", "yaml" } },
	-- yati = { enable = true },
	highlight = {
		enable = true,
		disable = { "yaml" },
		additional_vim_regex_highlighting = false,
	},
	autopairs = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["as"] = "@statement.outer",
				-- ["is"] = "@scopename.inner",
				["ib"] = "@block.inner",
				["ab"] = "@block.outer",
				["ak"] = "@comment.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<C-l>"] = "@parameter.inner",
				["<C-j>"] = "@statement.outer",
			},
			swap_previous = {
				["<C-h>"] = "@parameter.inner",
				["<C-k>"] = "@statement.outer",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				[")"] = "@block.outer",
			},
			goto_previous_start = {
				["("] = "@block.outer",
			},
		},
	},
	textsubjects = {
		enable = true,
		keymaps = {
			["."] = "textsubjects-smart",
			[";"] = "textsubjects-container-outer",
		},
	},
})
