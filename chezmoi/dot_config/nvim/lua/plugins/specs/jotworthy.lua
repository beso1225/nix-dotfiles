return {
  "beso1225/jev-jotworthy",
  cmd = { "Jotworthy" },
  keys = {
    {
      "<leader>oj",
      "<cmd>Jotworthy<CR>",
      mode = { "n", "x" },
      desc = "Judge text for today's Obsidian note",
    },
  },
  config = function()
    require("jotworthy").setup({
      threshold = 0.6,
    })
  end,
}
