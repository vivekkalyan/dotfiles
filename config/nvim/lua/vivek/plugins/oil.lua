return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-r>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["="] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["gh"] = "actions.toggle_hidden",
      ["C-v"] = "actions.select_vsplit",
      ["C-s"] = "actions.select_split",
      ["~"] = {
        desc = "Open home directory",
        callback = function()
          vim.cmd("edit $HOME")
        end,
      },
      ["gd"] = {
        desc = "Toggle detail view",
        callback = function()
          local oil = require("oil")
          local config = require("oil.config")
          if #config.columns == 1 then
            oil.set_columns({ "icon", "permissions", "size", "mtime" })
          else
            oil.set_columns({ "icon" })
          end
        end,
      },
    },
    view_options = {
      show_hidden = true,
    },
  },
  config = function(_, opts)
    local oil = require("oil")
    oil.setup(opts)
    vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
    vim.keymap.set("n", "_", function()
      oil.open(vim.fn.getcwd())
    end, { desc = "Open cwd" })
  end,
}
