require("Comment").setup()
vim.api.nvim_set_keymap("n", "", '<cmd>lua require("Comment.api").toggle_current_linewise()<cr>', {})
vim.api.nvim_set_keymap(
	"x",
	"",
	'<esc><cmd>lua require("Comment.api").toggle_blockwise_op(vim.fn.visualmode())<cr>',
	{}
)
