local repo = assert(os.getenv("REPO_ROOT"), "REPO_ROOT is required")

vim.opt.runtimepath:prepend(repo .. "/home-manager/nvim")

local treesitter = require("plugins.config.treesitter")
local parsers = treesitter.ensure_installed()
assert(vim.list_contains(parsers, "haskell"), "Haskell must be installed as a Tree-sitter parser")

local language_plugins = dofile(repo .. "/home-manager/nvim/lua/plugins/specs/lang.lua")
local haskell_tools
for _, plugin in ipairs(language_plugins) do
  if plugin[1] == "mrcjkb/haskell-tools.nvim" then
    haskell_tools = plugin
    break
  end
end

assert(haskell_tools, "haskell-tools.nvim must be registered")
assert(haskell_tools.version == "^10", "haskell-tools.nvim must pin its major version")
assert(haskell_tools.lazy == false, "haskell-tools.nvim must manage its own lazy initialization")

haskell_tools.init()
local settings = vim.g.haskell_tools.hls.settings.haskell
assert(settings.formattingProvider == "fourmolu")
assert(settings.cabalFormattingProvider == "cabal-gild")

print("haskell neovim configuration: ok")
