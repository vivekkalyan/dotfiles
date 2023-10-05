return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      -- config colorscheme
      local kanagawa = require("kanagawa")

      kanagawa.setup({
        keywordStyle = { italic = false, bold = true },
        colors = { -- add/modify theme and palette colors
          palette = { dragonAsh = "#737373" },
        },
      })
      -- load colorscheme
      vim.cmd([[colorscheme kanagawa-dragon]])
    end,
  },
  { "romainl/Apprentice", lazy = true },
  { "catppuccin/nvim", lazy = true },
  { "AlexvZyl/nordic.nvim", lazy = true },
  { "savq/melange-nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "rmehri01/onenord.nvim", lazy = true },
}
