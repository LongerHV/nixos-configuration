local M = {}
local lspconfig = require("lspconfig")
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Open diagnostics" })
vim.keymap.set("n", "<C-f>", "<nop>") -- Disable default binding

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
		vim.keymap.set("n", "<space>r", vim.lsp.buf.rename, opts("Rename symbol"))
		vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, opts("Code actions"))
		vim.keymap.set("n", "<leader>r", telescope.lsp_references, opts("Open references picker"))
		vim.keymap.set("n", "<C-f>", function()
			vim.lsp.buf.format({ async = true })
		end, opts("Format buffer"))
	end,
})

require("mini.completion").setup()

function M.setup_servers(json_config)
	local f = io.open(json_config, "r")
	if not f then
		return
	end
	local lsp_servers = vim.json.decode(f:read("all*"))
	f:close()
	if lsp_servers == nil then
		return
	end
	for server, config in pairs(lsp_servers) do
		if server == "lua_ls" then
			config.settings.Lua.workspace.library = vim.api.nvim_get_runtime_file("", true)
		end
		lspconfig[server].setup(config)
	end
end

return M
