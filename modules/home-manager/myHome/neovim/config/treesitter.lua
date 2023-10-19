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
})
