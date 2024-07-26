return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter.configs")

      -- configure treesitter
      treesitter.setup({
        -- ensure these language parsers are installed
        ensure_installed = {
          "bash",
          "css",
          "gitignore",
          "html",
          "javascript",
          "json",
          "ledger",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        -- auto install above language parsers
        auto_install = true,
        -- enable syntax highlighting
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = true },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = {
          enable = true,
        },
        -- enable incremental selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<nop>",
            node_incremental = "v",
            scope_incremental = "<nop>",
            node_decremental = "V",
          },
        },
      })
      -- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
      -- override the Neovim internal get_option function which is called whenever the commentstring is requested
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring"
          and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },
}
