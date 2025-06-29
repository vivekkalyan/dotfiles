return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    -- If treesitter is already loaded, we need to run config again for textobjects
    local Config = require("lazy.core.config")
    if Config.plugins["nvim-treesitter"] and Config.plugins["nvim-treesitter"]._.loaded then
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- Assignment
              ["a="] = { query = "@assignment.outer", desc = "outer assignment" },
              ["i="] = { query = "@assignment.inner", desc = "inner assignment" },

              -- Parameters/Arguments
              ["a,"] = { query = "@parameter.outer", desc = "outer parameter" },
              ["i,"] = { query = "@parameter.inner", desc = "inner parameter" },

              -- Conditionals
              ["ai"] = { query = "@conditional.outer", desc = "outer conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "inner conditional" },

              -- Loops
              ["al"] = { query = "@loop.outer", desc = "outer loop" },
              ["il"] = { query = "@loop.inner", desc = "inner loop" },

              -- Blocks
              ["ak"] = { query = "@block.outer", desc = "outer block" },
              ["ik"] = { query = "@block.inner", desc = "inner block" },

              -- Functions
              ["af"] = { query = "@function.outer", desc = "outer function" },
              ["if"] = { query = "@function.inner", desc = "inner function" },
              ["au"] = { query = "@call.outer", desc = "outer function call" },
              ["iu"] = { query = "@call.inner", desc = "inner function call" },

              -- Classes
              ["ac"] = { query = "@class.outer", desc = "outer class" },
              ["ic"] = { query = "@class.inner", desc = "inner class" },

              -- Numbers
              ["in"] = { query = "@number.inner", desc = "inner number" },
            },
            -- set selection mode for each query
            -- not able to set this due to bug it seems: https://github.com/nvim-treesitter/nvim-treesitter-textobjects/pull/435
            selection_modes = {
              ["@parameter.outer"] = "v", -- charwise
              ["@function.outer"] = "V", -- linewise
              ["@class.outer"] = "V", -- linewise
              ["@conditional.outer"] = "V", -- linewise
            },
            include_surrounding_whitespace = function(a)
              return a.selection_mode == "V"
            end,
          },
          swap = {
            enable = true,
            swap_next = {
              [">K"] = { query = "@block.outer", desc = "Swap next block" },
              [">F"] = { query = "@function.outer", desc = "Swap next function" },
              [">C"] = { query = "@class.outer", desc = "Swap next class" },
              [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
            },
            swap_previous = {
              ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
              ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
              ["<C"] = { query = "@class.outer", desc = "Swap previous class" },
              ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]k"] = { query = "@block.outer", desc = "Next block start" },
              ["]f"] = { query = "@function.outer", desc = "Next function start" },
              ["]c"] = { query = "@class.outer", desc = "Next class start" },
              ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
            },
            goto_next_end = {
              ["]K"] = { query = "@block.outer", desc = "Next block end" },
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
              ["]C"] = { query = "@class.outer", desc = "Next class end" },
              ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
            },
            goto_previous_start = {
              ["[k"] = { query = "@block.outer", desc = "Previous block start" },
              ["[f"] = { query = "@function.outer", desc = "Previous function start" },
              ["[c"] = { query = "@class.outer", desc = "Previous class start" },
              ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
            },
            goto_previous_end = {
              ["[K"] = { query = "@block.outer", desc = "Previous block end" },
              ["[F"] = { query = "@function.outer", desc = "Previous function end" },
              ["[C"] = { query = "@class.outer", desc = "Previous class end" },
              ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
            },
          },
          lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
              ["gp"] = "@function.outer",
              ["gP"] = "@class.outer",
            },
          },
        },
      })
    end
  end,
}
