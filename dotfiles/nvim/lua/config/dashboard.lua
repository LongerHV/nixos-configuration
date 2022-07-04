local db = require("dashboard")
local remap = vim.api.nvim_set_keymap

-- Dashboard header
db.custom_header = {
	"███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
	"████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
	"██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
	"██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
	"██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
	"",
	"",
}

-- Remaps
remap("n", "<Leader>ss", "<cmd>SessionSave<CR>", {})
remap("n", "<Leader>sl", "<cmd>SessionLoad<CR>", {})

db.custom_center = {
	{ icon = "  ",
		desc = "Find  File                              ",
		action = "Telescope find_files find_command=rg,--hidden,--files",
		shortcut = "SPC f f" },
	{ icon = "  ",
		desc = "File Browser                            ",
		action = "Telescope file_browser",
		shortcut = "SPC f e" },
	{ icon = "  ",
		desc = "Live grep                               ",
		action = "Telescope live_grep",
		shortcut = "SPC f g" },
}
