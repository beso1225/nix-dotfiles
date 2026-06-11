return {
  "saghen/blink.cmp",
  dependencies = {
    'saghen/blink.lib',
  },
  version = "*",
  build = function()
    require('blink.cmp').build():wait(60000)
  end,
  opts = {
    keymap = {
      preset = "default",
      ['<C-j>'] = { 'select_next' },
      ['<C-k>'] = { 'select_prev' },
      ['<C-y>'] = { 'accept', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<C-p>'] = { 'show_signature', 'show_signature', 'fallback' },
    },
    snippets = {
      preset = "luasnip",
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
      per_filetype = {
        markdown = { "snippets", "lsp", "path" },
        latex = { "snippets", "lsp", "path" },
      },
    },
    cmdline = {
      enabled = not vim.g.vscode,
      completion = {
        menu = { auto_show = true },
      },
      keymap = {
        preset = "super-tab",
        ['<C-j>'] = { 'select_next' },
        ['<C-k>'] = { 'select_prev' },
      }
    },
    fuzzy = { implementation = "rust" },
  },
  opts_extend = { "sources.default" },
}
