-- Color theme
vim.cmd("colorscheme OceanicNext")
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.colorcolumn = "80"

-- Fix transparent background
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")
vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
vim.cmd("hi WinSeparator guibg=NONE")

-- Statusline
require("mini.statusline").setup()
vim.cmd("hi MiniStatuslineModeNormal guibg=#6699cc")
vim.cmd("hi MiniStatuslineModeInsert guibg=#99c794")
vim.cmd("hi MiniStatuslineModeVisual guibg=#f99157")
vim.cmd("hi MiniStatuslineModeReplace guibg=#ec5f67")
vim.cmd("hi MiniStatuslineModeCommand guibg=#65737e")
