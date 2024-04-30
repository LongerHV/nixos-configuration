local gitsigns = require("gitsigns")

gitsigns.setup({
	on_attach = function(_)
		-- Actions
		vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
		vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
		vim.keymap.set("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage hunk" })
		vim.keymap.set("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset hunk" })
		vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
		vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
		vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
		vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
		vim.keymap.set("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "Blame line" })
		vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
		vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "Diffthis" })
		vim.keymap.set("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end, { desc = "Diffthis ~" })
		vim.keymap.set("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted" })

		-- Text object
		vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})
