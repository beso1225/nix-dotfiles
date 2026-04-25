---@type vim.lsp.Config
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      check = {
        command = "clippy",
      },
      checkOnSave = true,
      inlayHints = {
        enable = true,
        chainingHints = {
          enable = true,
        },
        typeHints = {
          enable = true,
          hideClosureInitialization = true,
        },
        parameterHints = {
          enable = true,
        },
        closureReturnTypeHints = {
          enable = "with_block",
        },
        lifetimeElisionHints = {
          enable = "skip_trivial",
          useParameterNames = true,
        },
        maxLength = 25,
        bindingModeHints = {
          enable = true,
        },
        closureCaptureHints = {
          enable = true,
        },
        discriminantHints = {
          enable = "fieldless",
        },
        expressionAdjustmentHints = {
          enable = "reborrow",
        },
        rangeExpressionHints = {
          enable = true,
        },
      }
    }
  },
}
