return {
  {
    "mrcjkb/rustaceanvim",
    version = "^8",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { replace_builtin_hover = false },
          float_win_config = { border = "rounded" },
          inlay_hints = { auto = true },
          code_actions = { ui_select_fallback = true },
        },
        server = {
          on_attach = function(_, bufnr)
            local opts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "<leader>ra", function() vim.cmd.RustLsp "codeAction" end,
              vim.tbl_extend("force", opts, { desc = "Rust code action" }))
            vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp "debuggables" end,
              vim.tbl_extend("force", opts, { desc = "Rust debuggables" }))
            vim.keymap.set("n", "<leader>rr", function() vim.cmd.RustLsp "runnables" end,
              vim.tbl_extend("force", opts, { desc = "Rust runnables" }))
            vim.keymap.set("n", "<leader>rt", function() vim.cmd.RustLsp "testables" end,
              vim.tbl_extend("force", opts, { desc = "Rust testables" }))
            vim.keymap.set("n", "<leader>rm", function() vim.cmd.RustLsp "expandMacro" end,
              vim.tbl_extend("force", opts, { desc = "Expand macro" }))
            vim.keymap.set("n", "<leader>rc", function() vim.cmd.RustLsp "openCargo" end,
              vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))
            vim.keymap.set("n", "<leader>rp", function() vim.cmd.RustLsp "parentModule" end,
              vim.tbl_extend("force", opts, { desc = "Parent module" }))
            vim.keymap.set("n", "<leader>rj", function() vim.cmd.RustLsp "joinLines" end,
              vim.tbl_extend("force", opts, { desc = "Join lines" }))
            vim.keymap.set("n", "<leader>rs", function() vim.cmd.RustLsp "ssr" end,
              vim.tbl_extend("force", opts, { desc = "Structural search replace" }))
            vim.keymap.set("n", "<leader>re", function() vim.cmd.RustLsp "explainError" end,
              vim.tbl_extend("force", opts, { desc = "Explain error" }))
            vim.keymap.set("n", "<leader>rD", function() vim.cmd.RustLsp "renderDiagnostic" end,
              vim.tbl_extend("force", opts, { desc = "Render diagnostic" }))
            vim.keymap.set("n", "K", function() vim.cmd.RustLsp { "hover", "actions" } end,
              vim.tbl_extend("force", opts, { desc = "Rust hover actions" }))
          end,
        },
        default_settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
              extraArgs = { "--all", "--", "-W", "clippy::all" },
            },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            procMacro = {
              enable = true,
              attributes = { enable = true },
            },
            inlayHints = {
              enable = true,
              chainingHints = { enable = true },
              typeHints = { enable = true, hideClosureInitialization = true },
              parameterHints = { enable = true },
              closureReturnTypeHints = { enable = "with_block" },
              lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
              maxLength = 25,
              bindingModeHints = { enable = true },
              closureCaptureHints = { enable = true },
              discriminantHints = { enable = "fieldless" },
              expressionAdjustmentHints = { enable = "reborrow" },
              rangeExclusiveHints = { enable = true },
            },
            completion = {
              autoimport = { enable = true },
              postfix = { enable = true },
              callable = { snippets = "fill_arguments" },
              fullFunctionSignatures = { enable = true },
              privateEditable = { enable = true },
            },
            imports = {
              granularity = { group = "module" },
              prefix = "self",
              preferNoStd = false,
            },
            lens = {
              enable = true,
              references = { enable = true, adt = { enable = true }, enumVariant = { enable = true }, method = { enable = true }, trait = { enable = true } },
              implementations = { enable = true },
              run = { enable = true },
              debug = { enable = true },
            },
            diagnostics = {
              enable = true,
              experimental = { enable = true },
              styleLints = { enable = true },
            },
            semanticHighlighting = {
              operator = { specialization = { enable = true } },
              punctuation = { enable = true, specialization = { enable = true } },
              strings = { enable = true },
            },
            hover = {
              actions = {
                enable = true,
                references = { enable = true },
                run = { enable = true },
                debug = { enable = true },
                gotoTypeDef = { enable = true },
                implementations = { enable = true },
              },
              documentation = { enable = true, keywords = { enable = true } },
              links = { enable = true },
            },
            typing = {
              autoClosingAngleBrackets = { enable = true },
            },
            workspace = {
              symbol = { search = { kind = "all_symbols" } },
            },
            files = {
              excludeDirs = { ".git", "node_modules", ".direnv", "target/debug/build" },
            },
          },
        },
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-dap",
            name = "rt_lldb",
          },
        }
      }
    end,
  },
  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_view_method = "skim"
    end
  }
}
