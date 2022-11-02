-- Config for Language Servers installed by nix
return {
	clangd = {},
	nil_ls = {},
	pyright = {},
	dockerls = {},
	bashls = {},
	yamlls = require("yaml-companion").setup({}),
	terraformls = {},
	gopls = {},
	-- tsserver = {},
	taplo = {},
	eslint = { cmd = { "eslint", "--stdio" } },
	jsonls = { cmd = { "vscode-json-languageserver", "--stdio" } },
	sumneko_lua = {
		cmd = { "lua-language-server" },
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
					maxPreload = 10000,
				},
			},
		},
	},
	texlab = {
		settings = {
			texlab = {
				build = {
					onSave = true,
					forwardSearchAfter = true,
				},
				forwardSearch = {
					executable = "zathura",
					args = { "--synctex-forward", "%l:1:%f", "%p" },
				},
				chktex = {
					onOpenAndSave = true,
				},
			},
		},
	},
}
