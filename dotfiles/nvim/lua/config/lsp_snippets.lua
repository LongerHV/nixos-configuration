local remap = vim.api.nvim_set_keymap

-- Snippets
local function prequire(...)
	local status, lib = pcall(require, ...)
	if (status) then return lib end
	return nil
end

local luasnip = prequire('luasnip')
local cmp = prequire("cmp")

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = vim.fn.col(".") - 1
	if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
		return true
	else
		return false
	end
end

_G.tab_complete = function()
	if cmp and cmp.visible() then
		cmp.select_next_item()
	elseif luasnip and luasnip.expand_or_jumpable() then
		return t("<Plug>luasnip-expand-or-jump")
	elseif check_back_space() then
		return t("<Tab>")
	else
		cmp.complete()
	end
	return ""
end
_G.s_tab_complete = function()
	if cmp and cmp.visible() then
		cmp.select_prev_item()
	elseif luasnip and luasnip.jumpable(-1) then
		return t("<Plug>luasnip-jump-prev")
	else
		return t("<S-Tab>")
	end
	return ""
end

-- Remaps
remap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
remap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
remap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
remap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
remap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
remap("s", "<C-E>", "<Plug>luasnip-next-choice", {})

-- Snippets
require("luasnip/loaders/from_vscode").lazy_load({
	paths = { "~/.local/share/nvim/site/pack/packer/start/friendly-snippets" },
})
