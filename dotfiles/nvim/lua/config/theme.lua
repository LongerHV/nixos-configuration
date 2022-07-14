vim.cmd("colorscheme OceanicNext")

-- Color theme
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.colorcolumn = "80"

-- Fix transparent background
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")
vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
vim.cmd("hi WinSeparator guibg=NONE")

-- Status line
require("lualine").setup({
	options = { theme = "OceanicNext", globalstatus = true },
	extensions = { 'nvim-tree' },
})

-- Winbar
require("nvim-navic").setup({
	highlight = true,
})
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

-- Colorizer
require("colorizer").setup()

-- Decorations
require("dressing").setup({})
