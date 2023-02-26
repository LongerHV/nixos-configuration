local telescope = require("telescope")
local builtin = require("telescope.builtin")
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

telescope.load_extension("file_browser")

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
		e = { telescope.extensions.file_browser.file_browser, "File browser" },
	},
}, { prefix = "<leader>" })

local ok, yaml_companion = pcall(require, "yaml_companion")
if ok then
	wk.register({
		f = {
			y = { yaml_companion.open_ui_select, "YAML schema" },
		},
	}, { prefix = "<leader>" })
end
