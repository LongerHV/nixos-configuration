vim.g.mapleader = " "

-- Line numbering
vim.api.nvim_win_set_option(0, "number", true)
vim.api.nvim_win_set_option(0, "relativenumber", true)
vim.api.nvim_win_set_option(0, "wrap", false)

-- Better Markdown
vim.api.nvim_set_option("conceallevel", 0)

-- Search case
vim.api.nvim_set_option("ignorecase", true)
vim.api.nvim_set_option("smartcase", true)

-- Hide command line
vim.api.nvim_set_option("cmdheight", 0)

-- Minimal number of lines to scroll when the cursor gets off the screen
vim.api.nvim_set_option("scrolloff", 8)
vim.api.nvim_set_option("sidescrolloff", 8)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Git
require("gitsigns").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Mini.nvim
require("mini.pairs").setup()
require("mini.trailspace").setup()
require("mini.surround").setup()
require("mini.comment").setup({
	mappings = {
		comment = "<C-c>",
		comment_line = "<C-c>",
		comment_visual = "<C-c>",
	},
})

-- File explorer
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})

-- Add missing commentstring for nix files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nix" },
	group = vim.api.nvim_create_augroup("SetNixCommentstring", { clear = true }),
	callback = function()
		vim.o.commentstring = "# %s"
	end,
})

-- Indentline
require("ibl").setup({
	scope = {
		enabled = false,
	},
})

-- Indents
vim.api.nvim_set_option("tabstop", 4)
vim.api.nvim_set_option("shiftwidth", 4)
vim.api.nvim_set_option("smartindent", true)
vim.cmd("filetype indent plugin on")

-- Ollama
vim.keymap.set("n", "<leader>G", ":Gen<CR>", { desc = "Run Ollama" })
vim.keymap.set("v", "<leader>G", ":Gen<CR>", { desc = "Run Ollama" })
require("gen").prompts["Explain code"] = {
	prompt = "Explain the following code:\n```$filetype\n$text\n```",
}
