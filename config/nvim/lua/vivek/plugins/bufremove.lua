return {
  "echasnovski/mini.bufremove",
  keys = {
    {
      "<leader>qq",
      function()
        require("mini.bufremove").delete(0, false)
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>qQ",
      function()
        require("mini.bufremove").delete(0, true)
      end,
      desc = "Delete Buffer (Force)",
    },
  },
}
