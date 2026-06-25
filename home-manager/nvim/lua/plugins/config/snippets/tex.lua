local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    { trig = "figpkg", snippetType = "autosnippet" },
    t({
      "\\usepackage{silence}",
      "\\WarningFilter{caption}{Unknown document class}",
      "\\usepackage{graphicx}",
      "\\usepackage{subcaption}",
    })
  ),
}
