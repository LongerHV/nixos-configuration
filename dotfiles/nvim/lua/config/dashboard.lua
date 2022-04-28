local remap = vim.api.nvim_set_keymap

-- Dashboard header
vim.g.dashboard_custom_header = {
	"███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
	"████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
	"██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
	"██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
	"██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
}

-- Set picker
vim.g.dashboard_default_executive = "telescope"

-- Remaps
remap("n", "<Leader>ss", "<cmd>SessionSave<CR>", {})
remap("n", "<Leader>sl", "<cmd>SessionLoad<CR>", {})
vim.g.dashboard_custom_shortcut = {
	last_session = "|",
	find_history = "|",
	find_file = "|",
	new_file = "|",
	change_colorscheme = "|",
	find_word = "|",
	book_marks = "|",
}
