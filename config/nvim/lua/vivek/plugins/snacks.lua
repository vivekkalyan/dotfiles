return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
    gitbrowse = { enabled = true },
    indent = {
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
    },
    image = { enabled = true },
    notifier = { enabled = true },
    rename = { enabled = true },
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
    toggle = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    local format = require("vivek.util.format")
    format.snacks_toggle():map("<leader>uf")
    format.snacks_toggle(true):map("<leader>uF")

    -- Gitbrowse
    vim.keymap.set({ "n", "v" }, "<leader>gy", function()
      local Snacks = require("snacks")
      Snacks.gitbrowse({
        what = "permalink",
        open = function(url)
          vim.fn.setreg("+", url)
          vim.notify("Copied GitHub URL: " .. url, vim.log.levels.INFO)
        end,
      })
    end, { desc = "Copy GitHub permalink to clipboard" })

    vim.keymap.set("n", "<leader>go", function()
      Snacks.gitbrowse.open()
    end, { desc = "Open in GitHub" })

    Snacks.toggle.animate():map("<leader>ua")
    Snacks.toggle.treesitter({ name = " Treesitter Highlighting" }):map("<leader>ut")
    Snacks.toggle.diagnostics({ name = " Diagnostics" }):map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle.option("spell", { name = "󰓆 Spell Checking" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "󰖶 Wrap Long Lines" }):map("<leader>uw")
    Snacks.toggle
      .option(
        "conceallevel",
        { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }
      )
      :map("<leader>uc")
    Snacks.toggle
      .option("background", { off = "light", on = "dark", name = "Dark Background" })
      :map("<leader>ub")
    Snacks.toggle.zoom():map("<leader>uz")
    if vim.lsp.inlay_hint then
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end
  end,
}
