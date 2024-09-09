return {
  "yorickpeterse/nvim-pqf",
  event = "VeryLazy",
  enabled = true,
  config = function()
    require("pqf").setup({
      signs = {
        error = "",
        warning = "",
        info = "",
        hint = "",
      },
    })
  end,
}
