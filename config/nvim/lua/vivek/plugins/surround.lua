return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  -- remove some keymaps
  opts = {
    keymaps = {
      normal = "ys",
      normal_cur = "yss",
      normal_line = "yS",
      normal_cur_line = "ySS",
      visual = "S",
      delete = "ds",
      change = "cs",
      change_line = "cS",
    },
  },
}
