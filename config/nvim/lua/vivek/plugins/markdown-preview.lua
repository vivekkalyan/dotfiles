return {
  "selimacerbas/markdown-preview.nvim",
  name = "selim-markdown-preview.nvim",
  dependencies = { "selimacerbas/live-server.nvim" },
  cmd = { "MarkdownPreview", "MarkdownPreviewRefresh", "MarkdownPreviewStop" },
  ft = { "markdown" },
  config = function()
    require("markdown_preview").setup()
  end,
  keys = {
    {
      "<leader>cp",
      ft = "markdown",
      "<cmd>MarkdownPreview<cr>",
      desc = "Markdown Preview",
    },
  },
}
