-- Shared keymaps for navigation, search, diagnostics, and LSP actions.

-- Clear search highlights
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Toggle file explorer
vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true, desc = "Toggle file explorer" })

-- Find files
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files" })

-- Live grep
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Live grep" })

-- These only activate when a Language Server connects to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }

		-- Go to definition
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

		-- Hover docs
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- Rename symbol
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		-- Code actions
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

		-- References
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

		-- Diagnostics navigation
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

		-- Floating diagnostic message
		vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)

		-- Manual formatting
		vim.keymap.set("n", "<leader>gf", function()
			require("conform").format({ lsp_fallback = true })
		end, opts)
	end,
})
