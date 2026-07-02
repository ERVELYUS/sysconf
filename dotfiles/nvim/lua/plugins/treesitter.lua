-- Treesitter on the new main branch: parser installation, highlighting, and indentation support.
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		require("nvim-treesitter").install({
			"c",
			"cpp",
			"cmake",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"python",
			"go",
			"json",
			"html",
			"css",
			"nix",
			"javascript",
			"typescript",
			"markdown",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"c",
				"cpp",
				"cmake",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"python",
				"go",
				"json",
				"html",
				"css",
				"nix",
				"javascript",
				"typescript",
				"markdown",
				"yaml",
			},
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
