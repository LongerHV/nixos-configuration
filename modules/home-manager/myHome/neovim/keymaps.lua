-- Remove annoying mapping
vim.keymap.set("n", "Q", "<nop>")

-- Navigation
vim.keymap.set("n", "ga", "<CMD>e #<CR>")

-- Copy and paste
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system register" })
vim.keymap.set("n", "<leader>y", '"+yy', { desc = "Yank to system register" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from system register" })
vim.keymap.set("v", "<leader>P", '"+P', { desc = "Paste from system register" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system register" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste from system register" })
vim.keymap.set("n", "Y", "y$")

-- Visual mode
vim.keymap.set("n", "vv", "V")
vim.keymap.set("n", "V", "v$")
