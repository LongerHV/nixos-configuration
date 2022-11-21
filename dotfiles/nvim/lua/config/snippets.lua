local luasnip = require("luasnip")
luasnip.setup({
	region_check_events = "CursorMoved",
})

-- Friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()
