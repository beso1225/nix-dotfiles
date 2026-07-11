return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local treesitter = require("plugins.config.treesitter")

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = treesitter.register_parsers,
      })
      treesitter.register_parsers()
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install({
        "rust",
        "c",
        "cpp",
        "python",
        "lua",
        "latex",
        "moonbit",
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  }
}
