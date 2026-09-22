local repo = assert(os.getenv("REPO_ROOT"), "REPO_ROOT is required")

vim.opt.runtimepath:prepend(repo .. "/chezmoi/dot_config/nvim")

local spec = dofile(repo .. "/chezmoi/dot_config/nvim/lua/plugins/specs/jotworthy.lua")

assert(spec[1] == "beso1225/jev-jotworthy")
assert(spec.dir == nil, "jotworthy must be installed from GitHub")
assert(vim.deep_equal(spec.cmd, { "Jotworthy" }))
assert(type(spec.keys) == "table")
assert(spec.keys[1][1] == "<leader>oj")
assert(spec.keys[1].mode[1] == "n")
assert(spec.keys[1].mode[2] == "x")
assert(type(spec.config) == "function")

print("jotworthy neovim configuration: ok")
