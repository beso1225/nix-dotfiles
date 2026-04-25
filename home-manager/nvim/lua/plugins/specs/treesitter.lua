return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        require("nvim-treesitter").setup({})
        require("nvim-treesitter").install({
            "rust",
            "c",
            "cpp",
            "python",
            "lua",
            "latex",
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

