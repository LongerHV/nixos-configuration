local telescope = require("telescope")
local builtin = require("telescope.builtin")
local utils = require("telescope.utils")
local wk = require("which-key")

telescope.setup({
	defaults = {
		layout_config = {
			horizontal = {
				width = 0.9,
			},
		},
	},
})

wk.register({
	T = { builtin.builtin, "Telescope - find picker" },
	f = {
		name = "Telescope",
		f = { builtin.find_files, "Find file" },
		g = { builtin.live_grep, "Live grep" },
		b = { builtin.buffers, "Buffers" },
		h = { builtin.help_tags, "Help tags" },
		t = { builtin.treesitter, "Treesitter" },
		r = { builtin.lsp_references, "References" },
		c = { builtin.commands, "Commands" },
		e = {
			function()
				builtin.file_browser({ cwd = utils.buffer_dir() })
			end,
			"File browser",
		},
	},
}, { prefix = "<leader>" })
