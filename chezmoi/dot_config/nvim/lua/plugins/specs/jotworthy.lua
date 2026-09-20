local jotworthy_dir = vim.fn.expand("~/ghq/github.com/beso1225/jev-jotworthy")

return {
  dir = jotworthy_dir,
  name = "jotworthy",
  cmd = { "Jotworthy" },
  keys = {
    {
      "<leader>oj",
      "<cmd>Jotworthy<CR>",
      mode = { "n", "x" },
      desc = "Judge text for today's Obsidian note",
    },
  },
  cond = function()
    return vim.fn.isdirectory(jotworthy_dir) == 1
  end,
  config = function()
    require("jotworthy").setup({
      threshold = 0.6,
    })
  end,
}
