local null_ls = require("null-ls")
null_ls.setup({
	debug = false;
	sources = {
		-- Python
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.isort,
		null_ls.builtins.diagnostics.pylama,

		-- Shell
		null_ls.builtins.formatting.shfmt,
		null_ls.builtins.formatting.shellharden,
		null_ls.builtins.diagnostics.shellcheck,
		null_ls.builtins.code_actions.shellcheck,

		-- JS yaml html markdown
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.diagnostics.markdownlint,

		-- C/C++
		null_ls.builtins.diagnostics.cppcheck,

		-- Go
		null_ls.builtins.diagnostics.golangci_lint,

		-- Lua
		null_ls.builtins.diagnostics.selene,

		-- Spelling
		-- null_ls.builtins.completion.spell,
		null_ls.builtins.diagnostics.codespell.with({
			args = { "--builtin", "clear,rare,code", "-" },
		}),

		-- Nix
		null_ls.builtins.diagnostics.statix,
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.formatting.nixpkgs_fmt,

		-- Git
		null_ls.builtins.code_actions.gitsigns,
		null_ls.builtins.diagnostics.gitlint,
	},
	on_attach = require("config.lsp").common_on_attach,
})
