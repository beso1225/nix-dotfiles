local M = {}

function M.ensure_installed()
  return {
    "rust",
    "c",
    "cpp",
    "python",
    "lua",
    "latex",
    "moonbit",
    "haskell",
  }
end

function M.moonbit_parser_config()
  return {
    install_info = {
      url = "https://github.com/moonbitlang/tree-sitter-moonbit",
      queries = "queries",
    },
    tier = 2,
  }
end

function M.register_parsers()
  require("nvim-treesitter.parsers").moonbit = M.moonbit_parser_config()
end

return M
