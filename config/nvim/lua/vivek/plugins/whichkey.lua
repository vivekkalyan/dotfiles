return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local whichkey = require("which-key")
    whichkey.add({
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>t", group = "test" },
    })
  end,
}
