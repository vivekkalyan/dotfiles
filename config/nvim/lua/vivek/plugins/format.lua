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
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  -- Everything in opts will be passed to setup()
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      rust = { "rustfmt" },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
    },
    -- only format changed lines on save
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
        return
      end
      local ignore_filetypes = { "lua" }
      if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
        return { timeout_ms = 500, lsp_fallback = true }
      end
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath == "" then
        return { timeout_ms = 500, lsp_fallback = true }
      end

      local diff_cmd = "git diff --unified=0 -- " .. vim.fn.shellescape(filepath)
      local diff = vim.fn.system(diff_cmd)
      if vim.v.shell_error ~= 0 then
        return { timeout_ms = 500, lsp_fallback = true }
      end

      local lines = diff:gmatch("[^\n\r]+")
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
      if vim.tbl_isempty(ranges) then
        return { timeout_ms = 500, lsp_fallback = true }
      end
      local format = require("conform").format
      for _, range in ipairs(ranges) do
        format({ range = range })
      end
    end,
  },
  init = function()
    -- Set formatexpr for gq
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
