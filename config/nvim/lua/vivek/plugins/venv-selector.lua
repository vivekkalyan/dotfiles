return {
  "linux-cultist/venv-selector.nvim",
  branch = "regexp",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
    -- "mfussenegger/nvim-dap-python",
  },
  opts = {
    -- Your options go here
    -- name = "venv",
    -- auto_refresh = false
    notify_user_on_venv_activation = true,
  },
  ft = "python",
  keys = {
    -- Keymap to open VenvSelector to pick a venv.
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
  },
}
