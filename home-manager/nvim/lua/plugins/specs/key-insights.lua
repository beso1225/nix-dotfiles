return {
  "beso1225/nvim-key-insights",
  version = "v0.2.4",
  cmd = {
    "KeyInsightsStart",
    "KeyInsightsPause",
    "KeyInsightsStop",
    "KeyInsightsStatus",
    "KeyInsightsReport",
    "KeyInsightsAnalyze",
    "KeyInsightsOpenReport",
    "KeyInsightsPurge",
  },
  opts = {
    storage = {
      directory = vim.fn.expand("~/.local/state/key-insights/sessions/")
    },
    report = {
      analyzer = "key-insight",
      directory = vim.fn.expand("~/.local/state/key-insights/reports/"),
    },
  },
  config = function(_, opts)
    require("key-insights").setup(opts)
  end,

}
