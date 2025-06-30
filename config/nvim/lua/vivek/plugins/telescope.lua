return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "debugloop/telescope-undo.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "truncate " },
        mappings = {
          i = {
            ["<esc>"] = actions.close,
            -- change horizontal split keymap
            ["<C-x>"] = actions.nop,
            ["<C-s>"] = actions.select_horizontal,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("undo")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "List undo tree" })

    keymap.set("n", "<leader>fa", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "gb", "<cmd>Telescope buffers<cr>", { desc = "List open buffers" })
    keymap.set(
      "n",
      "<leader>ff",
      "<cmd>Telescope find_files<cr>",
      { desc = "Fuzzy find files in cwd, respects .gitignore" }
    )
    keymap.set(
      "n",
      "<leader>fF",
      "<cmd>Telescope find_files no_ignore=true<cr>",
      { desc = "Fuzzy find all files in cwd" }
    )
    keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "List help tags" })
    keymap.set(
      "n",
      "<leader>fk",
      "<cmd>Telescope keymaps<cr>",
      { desc = "List normal mode kepmaps" }
    )
    keymap.set(
      "n",
      "<leader>f*",
      "<cmd>Telescope grep_string<cr>",
      { desc = "Find string under cursor in cwd" }
    )

    keymap.set("n", "<leader>fg", "<cmd>Telescope git_commits<cr>", { desc = "List git commits" })
    keymap.set(
      "n",
      "<leader>fG",
      "<cmd>Telescope git_bcommits<cr>",
      { desc = "List buffer's git commits" }
    )
    keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "List all branches" })
  end,
}
