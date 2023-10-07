require("nvim-treesitter.configs").setup({
	auto_install = false, -- Parsers are managed by Nix
	indent = {
		enable = true,
		disable = { "python", "yaml" }, -- Yaml and Python indents are unusable
	},
	highlight = {
		enable = true,
		disable = { "yaml" }, -- Disable yaml highlighting because Helm sucks :<
		additional_vim_regex_highlighting = false,
	},
	-- autopairs = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
		colors = {
			"#6699CC",
			"#5FB3B3",
			"#99C794",
			"#FAC863",
			"#f99157",
			"#EC5F67",
			"#C594C5",
		},
	},
})

-- Workaround for TS rainbow messed up after file changes
local group = vim.api.nvim_create_augroup("RainbowFix", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost", "BufWritePost" }, {
	group = group,
	callback = function()
		vim.cmd("TSDisable rainbow | TSEnable rainbow")
	end,
})
