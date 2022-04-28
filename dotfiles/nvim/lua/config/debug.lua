local dap = require("dap")
local dapui = require("dapui")
local wk = require("which-key")

dapui.setup({})

wk.register({
	d = {
		name = "DAP",
		g = { dapui.toggle, "Toggle DAP UI" },
		b = { dap.toggle_breakpoint, "Toggle breakpoint" },
		B = {
			function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			"Set conditional breakpoint",
		},
		r = { dap.repl.toggle, "Toggle REPL" },
		c = { dap.continue, "Start/Continue debugging" },
		p = { dap.pause, "Pause" },
		t = { dap.terminate, "Terminate" },
		n = { dap.run_to_cursor, "Run to cursor" },
		e = { dap.step_over, "Step over" },
		i = { dap.step_into, "Step into" },
		o = { dap.step_out, "Step out" },
		u = { dap.up, "Go up the stack" },
		d = { dap.down, "Go down the stack" },
	},
}, { prefix = "<leader>" })

dap.adapters.python = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",

		program = "${file}",
	},
}
