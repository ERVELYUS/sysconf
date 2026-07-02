-- Formatting rules for the languages you use most often.
return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			cpp = { "clang-format" },
			c = { "clang-format" },
			lua = { "stylua" },
			python = { "isort", "black" },
			go = { "goimports", "gofmt" },
			nix = { "nixfmt" },
			cmake = { "cmake-format" },

			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			markdown = { "prettier" },
			yaml = { "prettier" },
		},

		-- Always format on save for every supported filetype.
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	},
}
