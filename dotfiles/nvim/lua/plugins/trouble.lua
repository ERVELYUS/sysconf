-- A clean diagnostics and references panel that is much nicer than scattered lists.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{
			"<leader>xx",
			function()
				require("trouble").toggle({ mode = "diagnostics", focus = true })
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>xq",
			function()
				require("trouble").toggle({ mode = "quickfix", focus = true })
			end,
			desc = "Quickfix list",
		},
		{
			"<leader>xr",
			function()
				require("trouble").toggle({ mode = "lsp_references", focus = true })
			end,
			desc = "References",
		},
	},
}
