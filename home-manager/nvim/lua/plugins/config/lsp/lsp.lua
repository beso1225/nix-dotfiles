local M = {}

function M.mason()
  require("mason").setup()
end

function M.mason_lspconfig()
  require("mason-lspconfig").setup({
    ensure_installed = {
      "lua_ls",
      "rust_analyzer",
      "pyright",
      "clangd",
      "texlab",
      --"moonbit-lsp",
    },
    automatic_installation = true,
    automatic_enable = {
      exclude = {
        "rust_analyzer",
      }
    },
  })
end

vim.lsp.enable('nixd')

-- vim.lsp.enable('rust_analyzer')
return M
