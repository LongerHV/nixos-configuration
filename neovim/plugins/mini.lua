require("mini.pairs").setup()
require("mini.trailspace").setup()
require("mini.surround").setup()

require("mini.notify").setup()
vim.api.nvim_set_hl(0, "MiniNotifyBorder", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "MiniNotifyNormal", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "MiniNotifyTitle", { link = "NormalFloat" })

require("mini.statusline").setup()
vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { bg = "#6699cc" })
vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { bg = "#99c794" })
vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { bg = "#f99157" })
vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bg = "#ec5f67" })
vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bg = "#65737e" })

require("mini.comment").setup({
	mappings = {
		comment = "<C-c>",
		comment_line = "<C-c>",
		comment_visual = "<C-c>",
	},
})
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},

	clues = {
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},

	window = {
		delay = 200,
		config = {
			width = 50,
		},
	},
})
