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
	tsserver = {
		init_options = {
			tsserver = {
				path = "/nix/store/7dl36ia2p7xcb51lzlly9iyb5w2049qq-typescript-4.8.4/bin/tsserver"
			}
		}
	},
	taplo = {},
	cssls = {},
	eslint = { settings = { format = false } },
	jsonls = { init_options = { provideFormatter = false } },
	html = { init_options = { provideFormatter = false } },
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
