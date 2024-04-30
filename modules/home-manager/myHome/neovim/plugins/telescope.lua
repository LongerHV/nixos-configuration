local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Open file picker" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Open buffer picker" })
vim.keymap.set("n", "<leader>H", builtin.help_tags, { desc = "Open help tags picker" })
vim.keymap.set("n", "<leader>c", builtin.commands, { desc = "Open help tags picker" })
vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Open live grep" })

vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
