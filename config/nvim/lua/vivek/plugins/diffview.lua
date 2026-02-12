return {
  "sindrets/diffview.nvim",
  keys = {
    { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gM", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview vs Main" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
  },
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
}
