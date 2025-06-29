return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["a="] = { query = "@assignment.outer", desc = "a assignment" },
            ["i="] = { query = "@assignment.inner", desc = "inner assignment" },

            ["a,"] = { query = "@parameter.outer", desc = "a parameter/field" },
            ["i,"] = { query = "@parameter.inner", desc = "inner parameter/field" },

            ["ai"] = { query = "@conditional.outer", desc = "a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "inner conditional" },

            ["al"] = { query = "@loop.outer", desc = "a loop" },
            ["il"] = { query = "@loop.inner", desc = "inner loop" },

            ["ak"] = { query = "@block.outer", desc = "a block" },
            ["ik"] = { query = "@block.inner", desc = "inner block" },

            ["af"] = { query = "@function.outer", desc = "a function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },

            ["ac"] = { query = "@class.outer", desc = "a class" },
            ["ic"] = { query = "@class.inner", desc = "inner class" },

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
            [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
          },
          swap_previous = {
            ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
            ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
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
      },
    })
  end,
}
