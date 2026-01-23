return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "kosayoda/nvim-lightbulb",
    -- "mizlan/delimited.nvim",
    "mrcjkb/rustaceanvim",
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "snacks.nvim", words = { "Snacks" } },
        },
      },
    },
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

    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 2,
        source = "if_many",
        -- prefix = "●",
        prefix = function(diagnostic)
          local icons = require("vivek.core.init").icons.diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
        end,
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = require("vivek.core.init").icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = require("vivek.core.init").icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = require("vivek.core.init").icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = require("vivek.core.init").icons.diagnostics.Info,
        },
      },
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
        severity_sort = true,
        -- Show severity icons in the floating window
        format = function(diagnostic)
          local icons = {
            [vim.diagnostic.severity.ERROR] = require("vivek.core.init").icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = require("vivek.core.init").icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = require("vivek.core.init").icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = require("vivek.core.init").icons.diagnostics.Info,
          }
          local icon = icons[diagnostic.severity] or ""
          return string.format("%s %s", icon, diagnostic.message)
        end,
      },
    })

    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- Enable inlay hints if the server supports it
      if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      -- Enable code lens if the server supports it
      if client.supports_method("textDocument/codeLens") then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = bufnr,
          callback = function()
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end,
        })
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show all places where symbol is used

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show where symbol is defined

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- show where symbol is declared (without implementation)

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts) -- show all implementations of interface/abstract class

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gy", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show where type of symbol is defined

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

      opts.desc = "Run CodeLens"
      keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)

      opts.desc = "Refresh CodeLens"
      keymap.set("n", "<leader>cL", function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end, opts)

      opts.desc = "Organise imports"
      keymap.set("n", "<leader>co", function()
        vim.lsp.buf.code_action({
          apply = true,
          context = { only = { "source.organizeImports" } },
        })
      end, opts) -- organise imports

      opts.desc = "Smart code rename"
      keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Smart File Rename"
      keymap.set("n", "<leader>cR", function()
        Snacks.rename.rename_file()
      end, opts) -- smart file rename

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
      keymap.set("n", "<leader>cd", vim.diagnostic.setloclist, opts) -- show diagnostics for line

      opts.desc = "Show documentation"
      keymap.set("n", "K", function()
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
      end, opts) -- shows documentation for symbol under the cursor

      opts.desc = "Show signature help"
      keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts) -- shows function/method signature information while typing arguments

      if client.name == "ruff" then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = vim.tbl_deep_extend("force", {}, cmp_blink.get_lsp_capabilities(), {
      general = {
        -- positionEncodings = { "utf-8", "utf-16", "utf-32" } <-- this is the default
        positionEncodings = { "utf-16" }, -- force all clients to use UTF-16
      },
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    })

    -- configure astro
    vim.lsp.config["astro"] = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    vim.lsp.config["harper_ls"] = {
      filetypes = { "markdown", "typst" },
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        ["harper-ls"] = {
          userDictPath = "",
          fileDictPath = "",
          linters = {
            SpellCheck = true,
            SpelledNumbers = false,
            AnA = true,
            SentenceCapitalization = true,
            UnclosedQuotes = true,
            WrongQuotes = false,
            LongSentences = true,
            RepeatedWords = true,
            Spaces = true,
            Matcher = true,
            CorrectNumberSuffix = true,
          },
          codeActions = {
            ForceStable = false,
          },
          markdown = {
            IgnoreLinkTitle = false,
          },
          diagnosticSeverity = "hint",
          isolateEnglish = false,
          dialect = "British",
          maxFileLength = 120000,
        },
      },
    }

    -- configure lua server
    vim.lsp.config["lua_ls"] = {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          hint = {
            enable = true,
            arrayIndex = "Disable",
            semicolon = "All",
          },
        },
      },
    }

    vim.lsp.config["ruff"] = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

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
            lens = {
              enable = true,
              run = {
                enable = true,
              },
              debug = {
                enable = true,
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = false,
              },
              chainingHints = {
                enable = true,
              },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = {
                enable = "never",
              },
              lifetimeElisionHints = {
                enable = "never",
                useParameterNames = false,
              },
              maxLength = 25,
              parameterHints = {
                enable = true,
              },
              reborrowHints = {
                enable = "never",
              },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
    }

    -- configure svelte
    vim.lsp.config["svelte"] = {
      -- lazyvim has this, but is it needed?
      -- capabilities = {
      --   workspace = {
      --     didChangeWatchedFiles = false,
      --   },
      -- },
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        svelte = {
          enable_ts_plugin = true,
        },
        typescript = {
          inlayHints = {
            parameterNames = {
              enabled = "all",
              suppressWhenArgumentMatchesName = true,
            },
            parameterTypes = {
              enabled = true,
            },
            variableTypes = {
              enabled = true,
              suppressWhenTypeMatchesName = true,
            },
            propertyDeclarationTypes = {
              enabled = true,
            },
            functionLikeReturnTypes = {
              enabled = true,
            },
            enumMemberValues = {
              enabled = true,
            },
          },
        },
      },
    }

    -- configure taplo server
    vim.lsp.config["taplo"] = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    -- configure typescript server
    vim.lsp.config["ts_ls"] = {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        completions = {
          completeFunctionCalls = true,
        },
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    }

    -- configure ty server
    vim.lsp.config["ty"] = {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,
}
