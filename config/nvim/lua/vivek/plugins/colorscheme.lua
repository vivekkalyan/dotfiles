return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- config color_overrides
      local catppuccin = require("catppuccin")

      catppuccin.setup({
        show_end_of_buffer = true,
        color_overrides = {
          mocha = {
            base = "#1c1c1c",
          },
        },
        highlight_overrides = {
          all = function(colors)
            -- make StatusLine and StatusLineNC be easier to read
            -- make IncSearch and CurSearch more pastel
            -- define colors for delimited plugin
            return {
              StatusLine = { bg = "#87875f", fg = "#1c1c1c" },
              StatusLineNC = { bg = "#444444", fg = "#87875f" },
              IncSearch = { bg = "#89b4fa", style = { "bold" } },
              CurSearch = { bg = "#f5c2e7", style = { "bold" } },
              DelimitedError = { bg = colors.red },
              DelimitedWarn = { bg = colors.red },
              DelimitedInfo = { bg = colors.red },
              DelimitedHint = { bg = colors.red },
            }
          end,
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
