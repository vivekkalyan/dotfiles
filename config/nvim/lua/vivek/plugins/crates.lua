return {
  "saecki/crates.nvim",
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  event = { "BufRead Cargo.toml" },
  opts = {
    completion = {
      cmp = { enabled = true },
      crates = {
        enabled = true,
        max_results = 12, -- The maximum number of search results to display
        min_chars = 3, -- The minimum number of charaters to type before completions begin appearing
      },
    },
  },
  config = function()
    local crates = require("crates")
    crates.setup({
      completion = {
        cmp = { enabled = true },
        crates = {
          enabled = true,
          max_results = 12, -- The maximum number of search results to display
          min_chars = 3, -- The minimum number of charaters to type before completions begin appearing
        },
      },
    })
    local cmp = require("cmp")
    cmp.setup.buffer({
      sources = { { name = "crates" } },
    })
  end,
}
