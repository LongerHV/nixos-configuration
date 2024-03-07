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

-- Add missing commentstring for nix files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nix", "terraform" },
	group = vim.api.nvim_create_augroup("SetHashCommentstring", { clear = true }),
	callback = function()
		vim.bo.commentstring = "# %s"
	end,
})

-- Indents
vim.api.nvim_set_option("tabstop", 4)
vim.api.nvim_set_option("shiftwidth", 4)
vim.api.nvim_set_option("smartindent", true)
vim.cmd("filetype indent plugin on")
