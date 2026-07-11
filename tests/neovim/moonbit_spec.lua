local repo = assert(os.getenv("REPO_ROOT"), "REPO_ROOT is required")

vim.opt.runtimepath:prepend(repo .. "/home-manager/nvim")

require("core.filetypes")

local function detected(filename)
  return vim.filetype.match({ filename = filename })
end

assert(detected("main.mbt") == "moonbit", ".mbt must use the moonbit filetype")
assert(detected("main.mbti") == "moonbit", ".mbti must use the moonbit filetype")
assert(detected("moon.pkg") == "moonbit", "moon.pkg must use the moonbit filetype")

local parser = require("plugins.config.treesitter").moonbit_parser_config()
assert(parser.install_info.url == "https://github.com/moonbitlang/tree-sitter-moonbit")
assert(parser.install_info.queries == "queries")
assert(parser.tier == 2)

local lsp = dofile(repo .. "/home-manager/nvim/after/lsp/moonbit_ls.lua")
assert(vim.deep_equal(lsp.cmd, { "moon-lsp" }))
assert(vim.deep_equal(lsp.filetypes, { "moonbit" }))
assert(vim.list_contains(lsp.root_markers, "moon.mod.json"))
assert(vim.list_contains(lsp.root_markers, "moon.pkg.json"))

print("moonbit neovim configuration: ok")
