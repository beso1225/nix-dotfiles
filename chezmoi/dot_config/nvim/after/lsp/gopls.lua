---@type vim.lsp.Config
return {
  cmd = { "nix", "develop", "--command", "gopls" },
  root_markers = {
    "go.work",
    "go.mod",
    ".git",
  },
  filetypes = {
    "go",
    "gomod",
    "gowork",
    "gotmpl",
  }
}
