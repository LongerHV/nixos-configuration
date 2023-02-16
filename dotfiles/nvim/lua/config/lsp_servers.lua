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
	tsserver = { init_options = { tsserver = { path = "" } } },
	taplo = {},
	cssls = {},
	eslint = { settings = { format = false } },
	jsonls = { init_options = { provideFormatter = false } },
	html = { init_options = { provideFormatter = false } },
	lua_ls = {
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
