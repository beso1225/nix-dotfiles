return {
  {
    "mfussenegger/nvim-lint",
    ft = "tex",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        tex = { "chktex" },
      }

      local group = vim.api.nvim_create_augroup("chktex-lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          if vim.bo.filetype == "tex" then
            lint.try_lint()
          end
        end,
        desc = "Run ChkTeX diagnostics",
      })
    end,
  },
}
