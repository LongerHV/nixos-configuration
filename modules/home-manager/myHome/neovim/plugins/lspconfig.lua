local M = {}
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
local util = require("lspconfig.util")
local efmconfig = require("lspconfig.server_configurations.efm")
local telescope = require("telescope.builtin")
local schemastore = require("schemastore")

vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Open diagnostics" })
vim.keymap.set("n", "<C-f>", "<nop>") -- Disable default binding
vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local function opts(desc)
			return { buffer = ev.buf, desc = desc }
		end
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Goto declaration"))
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto definition"))
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Goto implementation"))
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts("Hover"))
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts("Show signature"))
		vim.keymap.set("n", "<space>R", vim.lsp.buf.rename, opts("Rename symbol"))
		vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, opts("Code actions"))
		vim.keymap.set("n", "<leader>r", telescope.lsp_references, opts("Open references picker"))
		vim.keymap.set("n", "<C-f>", function()
			vim.lsp.buf.format({ async = true })
		end, opts("Format buffer"))
	end,
})

local extra_server_options = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	},
	jsonls = {
		settings = {
			json = {
				schemas = schemastore.json.schemas(),
				validate = { enable = true },
			},
		},
	},
	yamlls = {
		settings = {
			yaml = {
				schemas = schemastore.yaml.schemas(),
				schemaStore = {
					enable = false,
					url = "",
				},
			},
		},
	},
	tsserver = {
		on_attach = function(client, _bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		end,
	},
}

function M.setup_servers(lsp_servers)
	for server, config in pairs(vim.tbl_deep_extend("error", lsp_servers, extra_server_options)) do
		if vim.startswith(server, "efm_") then
			if config.root_dir then
				config.root_dir = util.root_pattern(config.root_dir)
			end
			configs[server] = efmconfig
		end
		lspconfig[server].setup(config)
	end
end

return M
