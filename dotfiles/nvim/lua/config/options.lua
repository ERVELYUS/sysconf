-- Core editor behavior for an IDE-like feel without touching theming.
vim.g.mapleader = " "
vim.g.format_on_save_enabled = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true

vim.opt.completeopt = { "menu", "menuone", "noselect" }
