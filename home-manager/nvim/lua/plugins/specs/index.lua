local spec = {
  { import = "plugins.specs.edit" },
  { import = "plugins.specs.lang" },
  { import = "plugins.specs.lsp" },
  { import = "plugins.specs.obsidian" },
  { import = "plugins.specs.treesitter" },
  { import = "plugins.specs.luasnip" },
  { import = "plugins.specs.mdpreview" },
}
if not vim.g.vscode then
  spec[#spec + 1] = { import = "plugins.specs.blink" }
  spec[#spec + 1] = { import = "plugins.specs.ui" }
  spec[#spec + 1] = { import = "plugins.specs.tokyonight" }
  spec[#spec + 1] = { import = "plugins.specs.copilot" }
end

return spec
