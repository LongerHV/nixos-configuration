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

-- Git
require("gitsigns").setup()

-- Mini.nvim
require("mini.pairs").setup()
require("mini.trailspace").setup()
require("mini.surround").setup()
require("mini.statusline")
require("mini.comment").setup({
	mappings = {
		comment = "<C-c>",
		comment_line = "<C-c>",
		comment_visual = "<C-c>",
	},
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
local indent_map = {
	c = { tabstop = 2, shiftwidth = 2, expandtab = true },
	cpp = { tabstop = 2, shiftwidth = 2, expandtab = true },
	nix = { tabstop = 2, shiftwidth = 2, expandtab = true },
	json = { tabstop = 2, shiftwidth = 2, expandtab = true },
	terraform = { tabstop = 2, shiftwidth = 2, expandtab = true },
	javascript = { tabstop = 2, shiftwidth = 2, expandtab = true },
	markdown = { tabstop = 2, shiftwidth = 2, expandtab = true },
	html = { tabstop = 2, shiftwidth = 2, expandtab = true },
	vue = { tabstop = 2, shiftwidth = 2, expandtab = true },
}
local group = vim.api.nvim_create_augroup("MyCustomIndents", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(indent_map),
	group = group,
	callback = function()
		local match = vim.fn.expand("<amatch>")
		for opt, val in pairs(indent_map[match]) do
			vim.api.nvim_set_option_value(opt, val, { scope = "local" })
		end
	end,
})
vim.cmd("filetype indent plugin on")

-- Ollama
vim.keymap.set("n", "<leader>G", ":Gen<CR>", { desc = "Run Ollama" })
vim.keymap.set("v", "<leader>G", ":Gen<CR>", { desc = "Run Ollama" })
require("gen").prompts["Explain code"] = {
	prompt = "Explain the following code:\n```$filetype\n$text\n```",
}
