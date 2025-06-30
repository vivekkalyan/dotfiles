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
    words = { enabled = true },
  },
}
