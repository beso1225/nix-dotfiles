local blink = require("blink.cmp")

vim.lsp.config["_global"] = {
    capabilities = blink.get_lsp_capabilities(),
}
