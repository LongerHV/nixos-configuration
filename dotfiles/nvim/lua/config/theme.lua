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
	extensions = { "nvim-tree" },
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff" },
		lualine_c = { "diagnostics" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	winbar = {
		lualine_a = { "filename" },
		lualine_b = {},
		lualine_c = { "%{%v:lua.require'nvim-navic'.get_location()%}" },
		lualine_x = {},
		lualine_y = { function()
			local schema = require("yaml-companion").get_buf_schema(0)
			if schema and schema.result[1].name ~= "none" then
				return schema.result[1].name
			end
			return ""
		end },
		lualine_z = {},
	},
	inactive_winbar = {
		lualine_a = { "filename" },
	},
})

-- Colorizer
require("colorizer").setup()

-- Decorations
require("dressing").setup({})
