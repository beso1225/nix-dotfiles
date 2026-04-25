return {
  "saghen/blink.cmp",
  build = "cargo build --release",
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
