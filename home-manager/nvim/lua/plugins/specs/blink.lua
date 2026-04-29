return {
  "saghen/blink.cmp",
  dependencies = {
    'saghen/blink.lib',
  },
  build = function()
    require('blink.cmp').build():wait(60000)
  end,
  opts = {
    keymap = {
      preset = "enter",
    },
    snippets = {
      preset = "luasnip",
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
    },
    cmdline = {
      enabled = not vim.g.vscode,
      completion = {
        menu = { auto_show = true },
      },
      keymap = {
        preset = "super-tab",
      }
    }
  },
  opts_extend = { "sources.default" },
}
