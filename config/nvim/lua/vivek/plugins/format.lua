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
      python = { "ruff_format" },
      javascript = { "prettier" },
    },
    -- only format changed lines on save
    format_on_save = function(bufnr)
      local ignore_filetypes = { "lua" }
      if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
        return { timeout_ms = 500, lsp_fallback = true }
      end
      local lines =
        vim.fn.system("git diff --unified=0 " .. vim.fn.bufname(bufnr)):gmatch("[^\n\r]+")
      local ranges = {}
      for line in lines do
        if line:find("^@@") then
          local line_nums = line:match("%+.- ")
          if line_nums:find(",") then
            local _, _, first, second = line_nums:find("(%d+),(%d+)")
            table.insert(ranges, {
              start = { tonumber(first), 0 },
              ["end"] = { tonumber(first) + tonumber(second), 0 },
            })
          else
            local first = tonumber(line_nums:match("%d+"))
            table.insert(ranges, {
              start = { first, 0 },
              ["end"] = { first + 1, 0 },
            })
          end
        end
      end
      local format = require("conform").format
      for _, range in pairs(ranges) do
        format({ range = range })
      end
    end,
  },
  init = function()
    -- Set formatexpr for gq
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
