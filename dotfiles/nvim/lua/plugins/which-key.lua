-- Keybinding helper that teaches you the mappings already described in your config.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",

    delay = 500,

    win = {
      no_overlap = true,
      border = "rounded",
      padding = { 1, 2 },
    },

    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
