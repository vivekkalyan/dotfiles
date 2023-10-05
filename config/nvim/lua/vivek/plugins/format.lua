return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Code Format buffer",
    },
  },
  -- Everything in opts will be passed to setup()
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
    },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
  init = function()
    -- Set formatexpr for gq
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
