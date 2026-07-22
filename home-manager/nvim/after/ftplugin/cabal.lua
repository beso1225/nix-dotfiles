vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run,
  { buffer = true, silent = true, desc = "Run Cabal code lens" })
