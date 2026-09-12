return {
  "beso1225/nvim-key-insights",
  version = "v0.2.3",
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
      directory = vim.fn.expand("~/.local/state/key-insights/sessions"),
    },
    report = {
      analyzer = "key-insights",
      directory = vim.fn.expand("~/.local/state/key-insights/reports"),
    },
  },
}
