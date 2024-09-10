return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    "hrsh7th/cmp-cmdline", -- cmdline completions
    "hrsh7th/cmp-calc", -- calculator completions
    "kirasok/cmp-hledger", -- hledger completions
    { "L3MON4D3/LuaSnip", build = "make install_jsregexp" }, -- snippet engine
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
    local cmp = require("cmp")
    local types = require("cmp.types")

    local luasnip = require("luasnip")
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })

    vim.keymap.set({ "i" }, "<C-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice()
      end
    end, { silent = true })

    local lspkind = require("lspkind")

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

    -- set priority in cmp ordering based on the kind of the item
    local kind_priority_map = {
      [types.lsp.CompletionItemKind.EnumMember] = 1,
      [types.lsp.CompletionItemKind.Method] = 2,
      [types.lsp.CompletionItemKind.Variable] = 3,
      [types.lsp.CompletionItemKind.Snippet] = 99,
      [types.lsp.CompletionItemKind.Text] = 100,
    }

    local compare_kind = function(entry1, entry2)
      local kind1 = entry1:get_kind()
      local kind2 = entry2:get_kind()
      kind1 = kind_priority_map[kind1] or kind1
      kind2 = kind_priority_map[kind2] or kind2
      if kind1 ~= kind2 then
        local diff = kind1 - kind2
        if diff < 0 then
          return true
        elseif diff > 0 then
          return false
        end
      end
    end

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      preselect = cmp.PreselectMode.None, -- ignores preselect requests from lsp
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), -- previous suggestion
        ["<C-n>"] = cmp.mapping(function() -- start completion if not started, else next suggetion
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            cmp.complete({ reason = cmp.ContextReason.Auto })
          end
        end),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "calc" }, -- calculator
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
        { name = "hledger" }, -- hledger accounts
      }),
      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
      sorting = {
        priority_weight = 100,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          compare_kind,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
    })

    -- use Insert instead of Select in cmdline
    local cmdline_mappings = {
      ["<C-n>"] = {
        c = function(fallback)
          if cmp.visible() then
            return cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })(fallback)
          else
            return cmp.mapping.complete({ reason = cmp.ContextReason.Auto })(fallback)
          end
        end,
      },
      ["<C-p>"] = {
        c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      },
      ["<C-e>"] = {
        c = cmp.mapping.abort(),
      },
    }

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(cmdline_mappings),
      sources = {
        { name = "buffer" },
      },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(cmdline_mappings),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
