return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local gitsigns = require("gitsigns")

    gitsigns.setup({
      signs = {
        add = {
          text = "+",
        },
        change = {
          text = ">",
        },
        delete = {
          text = "-",
        },
        topdelete = {
          text = "^",
        },
        changedelete = {
          text = "<",
        },
      },
      signs_staged = {
        add = {
          text = "+",
        },
        change = {
          text = ">",
        },
        delete = {
          text = "-",
        },
        topdelete = {
          text = "^",
        },
        changedelete = {
          text = "<",
        },
      },
      signs_staged_enable = true,
      preview_config = {
        -- Options passed to nvim_open_win
        border = "none",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]g", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end)

        map("n", "[g", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end)

        map("n", "]G", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next", { target = "staged" })
          end
        end)

        map("n", "[G", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev", { target = "staged" })
          end
        end)

        -- Actions
        map("n", "gs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "gS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "<leader>gp", gs.preview_hunk_inline, { desc = "Preview Hunk" })
        map("n", "<leader>gd", gs.diffthis, { desc = "Diff Hunk" })

        map("v", "gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage Hunk" })
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset Hunk" })

        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame current line" })
        map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle show deleted lines" })

        map("n", "<leader>gB", function()
          gs.blame()
        end, { desc = "Blame buffer" })
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame Line" })

        -- Text object
        map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    })
  end,
}
