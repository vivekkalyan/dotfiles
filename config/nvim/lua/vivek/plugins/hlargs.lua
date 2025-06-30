return {
  "m-demare/hlargs.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- link to color used by @parameter
    highlight = { link = "@parameter" },
  },
}
