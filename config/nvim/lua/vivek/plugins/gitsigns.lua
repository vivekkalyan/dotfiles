return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
  local gitsigns = require("gitsigns")

  gitsigns.setup {
    signs = {
      add          = {hl = 'GitSignsAdd'   , text = '+', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
      change       = {hl = 'GitSignsChange', text = '>', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
      delete       = {hl = 'GitSignsDelete', text = '-', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      topdelete    = {hl = 'GitSignsDelete', text = '^', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      changedelete = {hl = 'GitSignsChange', text = '<', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
    preview_config = {
      -- Options passed to nvim_open_win
      border = 'none',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']g', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true})

      map('n', '[g', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true})

      -- Actions
      map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })
      map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage Buffer" })
      map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
      map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
      map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset Buffer" })
      map("n", "<leader>gp", gs.preview_hunk_inline, { desc = "Preview Hunk" })
      map('n', '<leader>gd', gs.diffthis, { desc = "Diff Hunk"})

      map("v", "<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Stage Hunk" })
      map("v", "<leader>gr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset Hunk" })

      map('n', '<leader>tb', gs.toggle_current_line_blame)
      map('n', '<leader>td', gs.toggle_deleted)

      -- Text object
      map({'o', 'x'}, 'ig', ':<C-U>Gitsigns select_hunk<CR>')
    end
  }
  end,
}
