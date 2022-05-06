local remap = vim.api.nvim_set_keymap

-- Remove annoying mapping
remap("n", "Q", "<Nop>", { noremap = true })

-- Quick Fix lists
remap("n", "<C-k>", ":cnext<CR>", { noremap = true })
remap("n", "<C-j>", ":cprev<CR>", { noremap = true })
remap("n", "<C-q>", ":call ToggleQFList(1)<CR>", { noremap = true })
remap("n", "<C-l>", ":call ToggleQFList(0)<CR>", { noremap = true })

-- Copy and paste
remap("v", "<leader>y", '"+y', { noremap = true })
remap("n", "<leader>y", '"+yy', { noremap = true })
remap("v", "<leader>p", '"+p', { noremap = true })
remap("v", "<leader>P", '"+P', { noremap = true })
remap("n", "<leader>p", '"+p', { noremap = true })
remap("n", "<leader>P", '"+P', { noremap = true })
remap("n", "Y", "y$", { noremap = true })

-- Add relative jumps to jumplist
remap("n", "k", '(v:count > 5 ? "m\'" . v:count : "") . \'k\'', { noremap = true, expr = true })
remap("n", "j", '(v:count > 5 ? "m\'" . v:count : "") . \'j\'', { noremap = true, expr = true })

-- Moving text
remap("v", "<leader>j", ":m '>+1<CR>gv=gv", { noremap = true })
remap("v", "<leader>k", ":m '<-2<CR>gv=gv", { noremap = true })
-- remap("i", "<leader>j", "<esc>:m .+1<CR>==", { noremap = true })
-- remap("i", "<leader>k", "<esc>:m .-2<CR>==", { noremap = true })
remap("n", "<leader>j", ":m .+1<CR>==", { noremap = true })
remap("n", "<leader>k", ":m .-2<CR>==", { noremap = true })

-- Command shortcuts
remap("n", "<leader>F", ":Format<CR>", { noremap = true })
