local lsp = {}
local lsp_config = require("lspconfig")
local lsp_signature = require("lsp_signature")
local lsp_installer = require("nvim-lsp-installer")
local navic = require("nvim-navic")
local common_capabilities = require("cmp_nvim_lsp").default_capabilities()
common_capabilities.semanticTokensProvider = nil

function lsp.common_on_attach(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	local opts = { noremap = true, silent = true }
	buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "gk", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", "<leader>ca", "<cmd>CodeActionMenu<CR>", opts)
	buf_set_keymap("v", "<leader>ca", "<cmd>CodeActionMenu<CR>", opts)
	buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	buf_set_keymap("n", "<leader>o", [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format({async=true})' ]])

	lsp_signature.on_attach({
		floating_window_above_cur_line = true,
	})

	if client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end

	client.server_capabilities.semanticTokensProvider = nil
end

-- Setup servers installed by nix
for server, config in pairs(require("config.lsp_servers")) do
	config.on_attach = lsp.common_on_attach
	config.capabilities = common_capabilities
	config.capabilities.offsetEncoding = { "utf-16" }
	lsp_config[server].setup(config)
end

-- Setup servers installed by lsp-installer
lsp_installer.on_server_ready(function(server)
	local config = {
		on_attach = lsp.common_on_attach,
		capabilities = common_capabilities,
	}
	server:setup(config)
	vim.cmd([[ do User LspAttach Buffers ]])
end)

return lsp
