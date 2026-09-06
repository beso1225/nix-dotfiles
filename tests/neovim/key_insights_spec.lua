local repo = assert(os.getenv("REPO_ROOT"), "REPO_ROOT is required")

vim.opt.runtimepath:prepend(repo .. "/home-manager/nvim")

local spec = dofile(repo .. "/home-manager/nvim/lua/plugins/specs/key-insights.lua")

assert(spec[1] == "beso1225/nvim-key-insights")
assert(spec.version == "v0.2.0")
assert(spec.dir == nil, "key-insights must be installed by lazy.nvim")
assert(vim.deep_equal(spec.cmd, {
  "KeyInsightsStart",
  "KeyInsightsPause",
  "KeyInsightsStop",
  "KeyInsightsStatus",
  "KeyInsightsReport",
  "KeyInsightsAnalyze",
  "KeyInsightsOpenReport",
  "KeyInsightsPurge",
}))
assert(spec.lazy ~= false, "key-insights must remain lazy-loadable")
assert(spec.opts.storage.directory == vim.fn.expand("~/.local/state/key-insights/sessions"))
assert(spec.opts.report.analyzer == "key-insights")
assert(spec.opts.report.directory == vim.fn.expand("~/.local/state/key-insights/reports"))

print("key-insights neovim configuration: ok")
