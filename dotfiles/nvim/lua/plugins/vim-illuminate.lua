-- Highlights other occurrences of the symbol under the cursor using LSP and Treesitter.
return {
	"RRethy/vim-illuminate",
	config = function()
		require("illuminate").configure({
			providers = { "lsp", "treesitter" },
			delay = 100,
		})
	end,
}
