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
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>e", group = "env" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>y", group = "yank" },
      { "<leader>t", group = "test" },
      { "<leader>u", group = "toggle" },
      { "<leader>q", group = "quit/buffer" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "z", group = "fold" },
    })
  end,
}
