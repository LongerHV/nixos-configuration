require("Comment").setup({
	toggler = {
		line = "",
	},
	mappings = {
		basic = true,
		extra = false,
		extended = false,
	},
})

vim.api.nvim_set_keymap("v", "", '<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<cr>', {})
