return {
  "tzachar/highlight-undo.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    undo = {
      hlgroup = "IncSearch",
    },
    redo = {
      hlgroup = "IncSearch",
    },
  },
}
