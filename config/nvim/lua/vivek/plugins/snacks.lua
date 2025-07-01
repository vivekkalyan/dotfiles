return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
    indent = {
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
    },
    image = { enabled = true },
    notifier = { enabled = true },
    scroll = {
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
      animate_repeat = {
        delay = 100, -- delay in ms before using the repeat animation
        duration = { step = 5, total = 10 },
        easing = "linear",
      },
    },
    statuscolumn = {
      left = { "mark", "sign" }, -- priority of signs on the left (high to low)
      right = { "git", "fold" }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 50, -- refresh at most every 50ms
    },
    quickfile = { enabled = true },
    words = { enabled = true },
  },
}
