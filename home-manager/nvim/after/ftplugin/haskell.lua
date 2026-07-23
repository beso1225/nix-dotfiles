local haskell = require("haskell-tools")
local opts = { buffer = true, silent = true }

vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run,
  vim.tbl_extend("force", opts, { desc = "Run Haskell code lens" }))
vim.keymap.set("n", "<leader>hs", haskell.hoogle.hoogle_signature,
  vim.tbl_extend("force", opts, { desc = "Search Hoogle signature" }))
vim.keymap.set("n", "<leader>he", haskell.lsp.buf_eval_all,
  vim.tbl_extend("force", opts, { desc = "Evaluate Haskell snippets" }))
vim.keymap.set("n", "<leader>rr", haskell.repl.toggle,
  vim.tbl_extend("force", opts, { desc = "Toggle Haskell project REPL" }))
vim.keymap.set("n", "<leader>rf", function()
  haskell.repl.toggle(vim.api.nvim_buf_get_name(0))
end, vim.tbl_extend("force", opts, { desc = "Toggle Haskell buffer REPL" }))
vim.keymap.set("n", "<leader>rq", haskell.repl.quit,
  vim.tbl_extend("force", opts, { desc = "Quit Haskell REPL" }))
