return {
  "folke/which-key.nvim",
  dependencies = { "afreakk/unimpaired-which-key.nvim" },
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local whichkey = require("which-key")
    local unimpaired_whichkey = require("unimpaired-which-key")
    whichkey.register(unimpaired_whichkey.normal_mode)
    whichkey.register(unimpaired_whichkey.normal_mode_and_visual_mode, { mode = { "n", "v" } })
  end,
}
