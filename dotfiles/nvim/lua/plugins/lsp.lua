-- Language servers for C++, Python, Go, Nix, Lua, JSON, HTML, CSS, and CMake.
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"clangd",
				"lua_ls",
				"pyright",
				"gopls",
				"jsonls",
				"html",
				"cssls",
				"nil_ls",
				"neocmake",
			},
			automatic_installation = true,
		})

		-- C++
		vim.lsp.config("clangd", {
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
			},
		})
		vim.lsp.enable("clangd")

		-- Lua
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
				},
			},
		})
		vim.lsp.enable("lua_ls")

		-- Python
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})
		vim.lsp.enable("pyright")

		-- Go
		vim.lsp.config("gopls", {
			capabilities = capabilities,
			settings = {
				gopls = {
					gofumpt = true,
					staticcheck = true,
					usePlaceholders = true,
					completeUnimported = true,
				},
			},
		})
		vim.lsp.enable("gopls")

		-- JSON
		vim.lsp.config("jsonls", {
			capabilities = capabilities,
		})
		vim.lsp.enable("jsonls")

		-- HTML
		vim.lsp.config("html", {
			capabilities = capabilities,
		})
		vim.lsp.enable("html")

		-- CSS
		vim.lsp.config("cssls", {
			capabilities = capabilities,
		})
		vim.lsp.enable("cssls")

		-- Nix
		vim.lsp.config("nil_ls", {
			capabilities = capabilities,
		})
		vim.lsp.enable("nil_ls")

		-- CMake
		vim.lsp.config("neocmake", {
			capabilities = capabilities,
		})
		vim.lsp.enable("neocmake")
	end,
}
