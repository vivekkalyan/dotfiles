return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git Status" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
  },
  config = true,
}
