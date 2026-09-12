---@type vim.lsp.Config
return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs {}',
      },
      options = {
        home_manager = {
          expr = '(buildins.getFlake (toString ./.)).homeConfigurations."${builtins.getEnv "USER"}".options',
        }
      }
    }
  }
}
