return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- config color_overrides
      local catppuccin = require("catppuccin")

      catppuccin.setup({
        color_overrides = {
          mocha = {
            base = "#1c1c1c",
          },
        },
      })
      -- load colorscheme
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
  { "romainl/Apprentice", lazy = true },
  { "AlexvZyl/nordic.nvim", lazy = true },
  { "savq/melange-nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "rmehri01/onenord.nvim", lazy = true },
}
