local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local extras = require("luasnip.extras")
ls.setup({
	region_check_events = "CursorMoved",
})

-- Friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()

ls.add_snippets("nix", {
	s("if", {
		t("if "),
		i(1),
		t(" then "),
		i(2),
		t(" else "),
		i(0),
	}),
	s("enable", {
		t('enable = lib.mkEnableOption "'),
		i(1),
		t('";'),
	}),
	s("module", {
		t({ "{ config, lib, ... }:", "", "let", "  cfg = config." }),
		extras.rep(1),
		t({ ";", "in", "{", "  options." }),
		i(1),
		t({ " = with lib; {", '    enable = mkEnableOption "' }),
		f(function(args)
			local attrs = vim.split(args[1][1], ".", { plain = true })
			return attrs[#attrs]
		end, { 1 }),
		t({ '";', "  };", "", "  config." }),
		i(2),
		t(" = lib.mkIf cfg."),
		extras.rep(1),
		t(".enable { "),
		i(0),
		t({ " };", "}" }),
	}),
})
