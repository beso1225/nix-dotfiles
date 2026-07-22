local blink = require("blink.cmp")

vim.lsp.config("*", {
  capabilities = blink.get_lsp_capabilities(),
})
