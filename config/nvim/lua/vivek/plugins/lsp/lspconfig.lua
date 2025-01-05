return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "kosayoda/nvim-lightbulb",
    -- "mizlan/delimited.nvim",
    "mrcjkb/rustaceanvim",
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import blink plugin
    local cmp_blink = require("blink.cmp")

    -- import nvim-lightbulb
    local lightbulb = require("nvim-lightbulb")
    lightbulb.setup({
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = { enabled = true },
    })

    -- import delimited plugin
    -- local delimited = require("delimited")

    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }

    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gy", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "Show LSP Document Symbols"
      keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", opts) -- show lsp document symbols

      opts.desc = "Show LSP Workspace Symbols"
      keymap.set("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", opts) -- show lsp workspace symbols

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", function()
        if client.name == "rust-analyzer" then
          vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
        else
          vim.lsp.buf.code_action()
        end
      end, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Organise imports"
      keymap.set("n", "<leader>co", function()
        vim.lsp.buf.code_action({
          apply = true,
          context = { only = { "source.organizeImports" } },
        })
      end, opts) -- organise imports

      opts.desc = "Smart code rename"
      keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show line diagnostics"
      vim.keymap.set("n", "<C-w>d", function()
        vim.diagnostic.open_float({ scope = "cursor" })
      end, opts) -- open diagnostic window

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>cD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      -- keep this instead of bracketed.mini because it highlights diagnostic
      -- this doesn't work because it uses vim.diagnostic.jump, which my current machine doesnt have for some reason
      -- opts.desc = "Go to previous diagnostic"
      -- keymap.set("n", "[d", function()
      --   delimited.goto_prev({ float = false })
      -- end, opts) -- jump to previous diagnostic in buffer
      --
      -- opts.desc = "Go to next diagnostic"
      -- keymap.set("n", "]d", function()
      --   delimited.goto_next({ float = false })
      -- end, opts) -- jump to next diagnostic in buffer

      opts.desc = "Set diagnostics to location list"
      keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, opts) -- show diagnostics for line

      opts.desc = "Show documentation"
      keymap.set("n", "<leader>ck", function()
        if
          client.name == "taplo"
          and vim.fn.expand("%:t") == "Cargo.toml"
          and pcall(require, "crates") -- this depends on saecki/crates.nvim
          and require("crates").popup_available()
        then
          require("crates").show_popup()
        else
          vim.lsp.buf.hover()
        end
      end, opts) -- show documentation for what is under cursor

      opts.desc = "Show signature help"
      keymap.set("n", "<leader>cs", vim.lsp.buf.signature_help, opts) -- show documentation for what is under cursor

      if client.name == "ruff" then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_blink.get_lsp_capabilities()

    -- configure astro
    lspconfig["astro"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })

    -- configure python server
    lspconfig["pyright"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        pyright = {
          -- Using Ruff's import organizer
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            -- Ignore all files for analysis to exclusively use Ruff for linting
            ignore = { "*" },
          },
        },
      },
    })

    lspconfig["ruff"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure rust server
    vim.g.rustaceanvim = {
      server = {
        capabilities = capabilities,
        on_attach = on_attach,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            diagnostics = {
              enable = true,
            },
            -- add clippy to diagnostics
            checkOnSave = true,
          },
        },
      },
    }

    -- configure svelte
    lspconfig["svelte"].setup({
      -- lazyvim has this, but is it needed?
      -- capabilities = {
      --   workspace = {
      --     didChangeWatchedFiles = false,
      --   },
      -- },
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure taplo server
    lspconfig["taplo"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure typescript server
    lspconfig["ts_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        completions = {
          completeFunctionCalls = true,
        },
      },
    })
  end,
}
