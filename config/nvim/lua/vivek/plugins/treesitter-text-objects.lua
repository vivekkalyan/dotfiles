return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["a="] = {
              query = "@assignment.outer",
              desc = "Select outer part of an assignment region",
            },
            ["i="] = {
              query = "@assignment.inner",
              desc = "Select inner part of an assignment region",
            },

            ["a,"] = {
              query = "@parameter.outer",
              desc = "Select outer part of a parameter/field region",
            },
            ["i,"] = {
              query = "@parameter.inner",
              desc = "Select inner part of a parameter/field region",
            },

            ["ai"] = {
              query = "@conditional.outer",
              desc = "Select outer part of a conditional region",
            },
            ["ii"] = {
              query = "@conditional.inner",
              desc = "Select inner part of a conditional region",
            },

            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop region" },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop region" },

            ["ab"] = { query = "@block.outer", desc = "Select outer part of a block region" }, -- overrides default text object block of parenthesis to parenthesis
            ["ib"] = { query = "@block.inner", desc = "Select inner part of a block region" }, -- overrides default text object block of parenthesis to parenthesis

            ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },

            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },

            ["in"] = { query = "@number.inner", desc = "Select inner part of a number region" },
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
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
          },
          swap_previous = {
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
