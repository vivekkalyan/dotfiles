return {
  "saghen/blink.cmp",
  dependencies = "rafamadriz/friendly-snippets",
  event = "InsertEnter",
  version = "*",

  opts = {
    keymap = {
      preset = "none",
      ["<C-e>"] = { "hide" },
      ["<C-y>"] = { "select_and_accept" },

      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_next()
          else
            return cmp.show()
          end
        end,
        "fallback",
      },

      ["Up"] = { "select_prev", "fallback" },
      ["Down"] = { "select_next", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      ["<C-k>"] = { "snippet_forward", "fallback" },
      ["<C-j>"] = { "snippet_backward", "fallback" },
    },

    completion = {
      accept = {
        -- experimental auto-brackets support
        auto_brackets = {
          enabled = true,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = true,
      },
    },

    sources = {
      default = { "lazydev", "ecolog", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        ecolog = { name = "ecolog", module = "ecolog.integrations.cmp.blink_cmp" },
      },
    },

    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
