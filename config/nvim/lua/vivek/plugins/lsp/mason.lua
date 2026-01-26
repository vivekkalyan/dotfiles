return {
  "williamboman/mason.nvim",
  event = "VimEnter",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "astro",
        "harper_ls",
        "lua_ls",
        "ruff",
        "rust_analyzer",
        "svelte",
        "taplo",
        "ts_ls",
        "ty",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- formatters
        "biome",
        "stylua",
        "shfmt",

        -- linters
        "ruff",
      },
      start_delay = 1000, -- defer installs so UI isn't blocked on startup
    })

    mason_tool_installer.run_on_start()
  end,
}
