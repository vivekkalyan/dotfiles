return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  init = function()
    -- v4 moved keymap customization out of setup().
    -- Keep the default normal-mode mappings, but drop insert-mode mappings
    -- and the visual-line mapping (`gS`).
    vim.g.nvim_surround_no_insert_mappings = true
    vim.g.nvim_surround_no_visual_mappings = true
  end,
  config = function()
    require("nvim-surround").setup({})
    vim.keymap.set("x", "S", "<Plug>(nvim-surround-visual)", {
      desc = "Add a surrounding pair around a visual selection",
    })
  end,
}
