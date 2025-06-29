return {
  "echasnovski/mini.ai",
  event = "VeryLazy",
  opts = function()
    local ai = require("mini.ai")
    return {
      n_lines = 500,
      custom_textobjects = {
        ["="] = false, -- Use treesitter's assignment
        [","] = false, -- Use treesitter's parameter
        ["f"] = false, -- Use treesitter's function
        ["c"] = false, -- Use treesitter's class

        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
        e = { -- Word with case
          {
            "%u[%l%d]+%f[^%l%d]",
            "%f[%S][%l%d]+%f[^%l%d]",
            "%f[%P][%l%d]+%f[^%l%d]",
            "^[%l%d]+%f[^%l%d]",
          },
          "^().*()$",
        },
        g = function(ai_type)
          -- only buffer "g" for around textobject
          if ai_type == "a" then
            return require("vivek.util.mini").ai_buffer()
          end
          -- Return nil for inside to disable it
          return nil
        end,
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
      },
      mappings = {
        -- Next/last variants
        around_next = "an",
        inside_next = "in",
        around_last = "ah",
        inside_last = "ih",

        -- Use treesitter-textobjects movement instead
        goto_left = "",
        goto_right = "",
      },
    }
  end,
  config = function(_, opts)
    require("mini.ai").setup(opts)
    require("vivek.util").on_load("which-key.nvim", function()
      vim.schedule(function()
        require("vivek.util.mini").ai_whichkey(opts)
      end)
    end)
  end,
}
