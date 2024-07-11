return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git Status" },
    { "gC", "<cmd>Neogit commit<cr>", desc = "Git Commit" },
  },
  config = true,
}
