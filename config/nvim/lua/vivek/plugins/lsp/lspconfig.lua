return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "kosayoda/nvim-lightbulb",
    "mizlan/delimited.nvim",
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- import nvim-lightbulb
    local lightbulb = require("nvim-lightbulb")
    lightbulb.setup({
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = { enabled = true },
    })

    -- import delimited plugin
    local delimited = require("delimited")

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
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

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
      vim.keymap.set("n", "<leader>cd", function()
        vim.diagnostic.open_float({ scope = "cursor" })
      end, opts) -- open diagnostic window

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>cD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", function()
        delimited.goto_prev({ float = false })
      end, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", function()
        delimited.goto_next({ float = false })
      end, opts) -- jump to next diagnostic in buffer

      opts.desc = "Set diagnostics to location list"
      keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, opts) -- show diagnostics for line

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts) -- show documentation for what is under cursor

      if client.name == "ruff_lsp" then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

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

    lspconfig["ruff_lsp"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure rust server
    lspconfig["rust_analyzer"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure typescript server
    lspconfig["tsserver"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        completions = {
          completeFunctionCalls = true,
        },
      },
    })

    -- remove distracting virtual lines when doing edits
    -- toggle based on when Buffer modified state changes
    -- if buffer is modified (changes are being made): disable virtual lines
    -- if buffer is not modified (on open/write): enable virtual lines

    local diagnostic_augroup = vim.api.nvim_create_augroup("diagnostic", { clear = true })
    vim.api.nvim_create_autocmd({ "BufModifiedSet" }, {
      group = diagnostic_augroup,
      callback = function()
        local is_modified = vim.api.nvim_buf_get_option(0, "modified")
        vim.diagnostic.config({ virtual_lines = not is_modified })
      end,
    })

    vim.api.nvim_create_autocmd({ "BufReadPre" }, {
      group = diagnostic_augroup,
      callback = function()
        vim.diagnostic.config({ virtual_lines = true })
      end,
    })
  end,
}
