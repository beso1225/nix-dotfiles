local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    { trig = "mathpkg", snippetType = "snippet" },
    t({
      "\\usepackage{amssymb}",
      "\\usepackage{amsmath}",
      "\\usepackage{mathtools}",
      "\\usepackage{bm}",
    })
  ),
  s(
    { trig = "eqrefonly", snippetType = "snippet" },
    t("\\mathtoolsset{showonlyrefs=true}")
  ),
  s(
    { trig = "unitveccfg", snippetType = "snippet" },
    t({
      "\\newcommand{\\ex}{\\bm{e_x}}",
      "\\newcommand{\\ey}{\\bm{e_y}}",
      "\\newcommand{\\ez}{\\bm{e_z}}",
      "\\newcommand{\\exd}{\\bm{e'_x}}",
      "\\newcommand{\\eyd}{\\bm{e'_y}}",
      "\\newcommand{\\ezd}{\\bm{e'_z}}",
    })
  ),
  s(
    { trig = "diffcfg", snippetType = "snippet" },
    t("\\renewcommand{\\d}{\\mathrm{d}}")
  ),
  s(
    { trig = "tikzpkg", snippetType = "snippet" },
    t({
      "\\usepackage{tikz}",
      "\\usetikzlibrary{intersections,calc,arrows.meta}",
    })
  ),
  s(
    { trig = "listingstyle", snippetType = "snippet" },
    t({
      "\\lstset{",
      "    frame=tb,",
      "    basicstyle={\\small},",
      "    identifierstyle={\\small},",
      "    commentstyle={\\small\\ttfamily},",
      "    keywordstyle={\\small\\bfseries},",
      "    ndkeywordstyle={\\small},",
      "    stringstyle={\\small\\ttfamily},",
      "    breaklines=true,",
      "    columns=[l]{fullflexible},",
      "    numbers=left,",
      "    xrightmargin=0em,",
      "    xleftmargin=6em,",
      "    classoffset = 0,",
      "    numberstyle=\\scriptsize,",
      "    stepnumber=1,",
      "    lineskip=-0.5ex,",
      "    tabsize=4",
      "}",
    })
  ),
  s(
    { trig = "icodecfg", snippetType = "snippet" },
    t("\\newcommand{\\code}[1]{ \\texttt{\\detokenize{#1}} }")
  ),
  s(
    { trig = "eqsec", snippetType = "snippet" },
    t({
      "\\renewcommand{\\theequation}{\\arabic{section}.\\arabic{equation}}",
      "\\makeatletter",
      "\\@addtoreset{equation}{section}",
      "\\makeatother",
    })
  ),
  s(
    { trig = "figchapter", snippetType = "snippet" },
    t({
      "% Requires \\usepackage{chngcntr} and a document class with chapters.",
      "\\counterwithin{figure}{chapter}",
      "\\renewcommand{\\thefigure}{\\arabic{chapter}.\\arabic{figure}}",
    })
  ),
  s(
    { trig = "boxpkg", snippetType = "snippet" },
    t({
      "\\usepackage{tcolorbox}",
      "\\tcbuselibrary{breakable}",
      "\\tcbuselibrary{skins}",
    })
  ),
  s(
    { trig = "boxstyle", snippetType = "snippet" },
    t({
      "% Requires tcolorbox with the breakable and skins libraries (boxpkg).",
      "\\newtcolorbox{mysimplebox}[1]{%",
      "    breakable,",
      "    colframe=black, colback=white,",
      "    coltitle=black, colbacktitle=white,",
      "    boxrule=0.8pt, arc=0mm,",
      "    fonttitle=\\sffamily\\bfseries,",
      "    enhanced,",
      "    attach boxed title to top left={xshift=10mm,yshift=-3mm},",
      "    boxed title style={frame hidden},",
      "    title=#1",
      "}",
    })
  ),
  s(
    { trig = "questioncfg", snippetType = "snippet" },
    t({
      "% Requires mysimplebox (boxstyle) and its package setup (boxpkg).",
      "% question counter",
      "\\newcounter{problemnum}[section]",
      "\\renewcommand{\\theproblemnum}{\\arabic{section}.\\arabic{problemnum}}",
      "\\newcommand{\\prob}{\\theproblemnum}",
      "",
      "",
      "% question environment",
      "\\newenvironment{question}[2]{",
      "    \\refstepcounter{problemnum}",
      "    \\begin{mysimplebox}{#1\\prob}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
    })
  ),
  s(
    { trig = "theoremcfg", snippetType = "snippet" },
    t({
      "% Requires mysimplebox (boxstyle) and its package setup (boxpkg).",
      "% Shared counter for definitions, propositions, theorems, lemmas, and corollaries",
      "\\newcounter{theoremnum}[section]",
      "\\renewcommand{\\thetheoremnum}{\\arabic{section}.\\arabic{theoremnum}}",
      "\\newcommand{\\thm}{\\thetheoremnum}",
      "",
      "% definition environment",
      "\\newenvironment{definition}[2][\\thm]{",
      "    \\ifx#1\\thm\\refstepcounter{theoremnum}\\fi",
      "    \\begin{mysimplebox}{定義#1}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
      "",
      "% proposition environment",
      "\\newenvironment{proposition}[2][\\thm]{",
      "    \\ifx#1\\thm\\refstepcounter{theoremnum}\\fi",
      "    \\begin{mysimplebox}{命題#1}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
      "",
      "% theorem environment",
      "\\newenvironment{theorem}[2][\\thm]{",
      "    \\ifx#1\\thm\\refstepcounter{theoremnum}\\fi",
      "    \\begin{mysimplebox}{定理#1}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
      "",
      "% lemma environment",
      "\\newenvironment{lemma}[2][\\thm]{",
      "    \\ifx#1\\thm\\refstepcounter{theoremnum}\\fi",
      "    \\begin{mysimplebox}{補題#1}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
      "",
      "% corollary environment",
      "\\newenvironment{corollary}[2][\\thm]{",
      "    \\ifx#1\\thm\\refstepcounter{theoremnum}\\fi",
      "    \\begin{mysimplebox}{系#1}\\label{#2}",
      "}{",
      "    \\end{mysimplebox}",
      "}",
    })
  ),
  s(
    { trig = "hyperrefcfg", snippetType = "snippet" },
    t("\\usepackage[luatex,pdfencoding=auto]{hyperref}")
  ),
  s(
    { trig = "ltjsmargin", snippetType = "snippet" },
    t({
      "\\setlength{\\textwidth}{\\fullwidth}",
      "\\setlength{\\evensidemargin}{\\oddsidemargin}",
    })
  ),
  s(
    { trig = "geometrycfg", snippetType = "snippet" },
    {
      t("\\usepackage[margin="),
      i(1, "15"),
      t("truemm]{geometry}"),
    }
  ),
  s(
    { trig = "ltjsreport", snippetType = "snippet" },
    {
      t({ "\\documentclass{ltjsarticle}", "", "\\title{" }),
      i(1, "タイトル"),
      t({ "}", "\\author{" }),
      i(2, "著者"),
      t({ "}", "\\date{}", "", "\\begin{document}", "\\maketitle", "", "" }),
      i(3, "本文"),
      t({ "", "\\end{document}" }),
      i(0),
    }
  ),
  s(
    { trig = "tocfront", snippetType = "snippet" },
    {
      t({ "\\pagenumbering{roman}", "\\setcounter{tocdepth}{" }),
      i(1, "1"),
      t({ "}", "\\tableofcontents", "\\clearpage", "\\pagenumbering{arabic}" }),
      i(0),
    }
  ),
  s(
    { trig = "lstcode", snippetType = "snippet" },
    {
      t("\\begin{lstlisting}[caption={"),
      i(1, "説明"),
      t("}, label={lst:"),
      i(2, "名前"),
      t({ "}]", "" }),
      i(3, "コード"),
      t({ "", "\\end{lstlisting}" }),
      i(0),
    }
  ),
  s(
    { trig = "figtikz", snippetType = "snippet" },
    {
      t("\\begin{figure}["),
      i(1, "htbp"),
      t({ "]", "    \\centering", "    \\begin{tikzpicture}", "        " }),
      i(2, "描画コード"),
      t({ "", "    \\end{tikzpicture}", "    \\caption{" }),
      i(3, "説明"),
      t("}\\label{fig:"),
      i(4, "名前"),
      t({ "}", "\\end{figure}" }),
      i(0),
    }
  ),
  s(
    { trig = "qbox", snippetType = "snippet" },
    {
      t("\\begin{question}{"),
      i(1, "問題"),
      t("}{prob:"),
      i(2, "名前"),
      t({ "}", "    " }),
      i(3, "問題文"),
      t({ "", "\\end{question}" }),
      i(0),
    }
  ),
  s(
    { trig = "defbox", snippetType = "snippet" },
    {
      t("\\begin{definition}{def:"),
      i(1, "名前"),
      t({ "}", "    " }),
      i(2, "定義の内容"),
      t({ "", "\\end{definition}" }),
      i(0),
    }
  ),
  s(
    { trig = "propbox", snippetType = "snippet" },
    {
      t("\\begin{proposition}{prop:"),
      i(1, "名前"),
      t({ "}", "    " }),
      i(2, "命題の内容"),
      t({ "", "\\end{proposition}" }),
      i(0),
    }
  ),
  s(
    { trig = "thmbox", snippetType = "snippet" },
    {
      t("\\begin{theorem}{thm:"),
      i(1, "名前"),
      t({ "}", "    " }),
      i(2, "定理の内容"),
      t({ "", "\\end{theorem}" }),
      i(0),
    }
  ),
  s(
    { trig = "lembox", snippetType = "snippet" },
    {
      t("\\begin{lemma}{lem:"),
      i(1, "名前"),
      t({ "}", "    " }),
      i(2, "補題の内容"),
      t({ "", "\\end{lemma}" }),
      i(0),
    }
  ),
  s(
    { trig = "corbox", snippetType = "snippet" },
    {
      t("\\begin{corollary}{cor:"),
      i(1, "名前"),
      t({ "}", "    " }),
      i(2, "系の内容"),
      t({ "", "\\end{corollary}" }),
      i(0),
    }
  ),
  s(
    { trig = "simplebox", snippetType = "snippet" },
    {
      t("\\begin{mysimplebox}{"),
      i(1, "タイトル"),
      t({ "}", "    " }),
      i(2, "内容"),
      t({ "", "\\end{mysimplebox}" }),
      i(0),
    }
  ),
  s(
    { trig = "figpkg", snippetType = "autosnippet" },
    t({
      "\\usepackage{silence}",
      "\\WarningFilter{caption}{Unknown document class}",
      "\\usepackage{graphicx}",
      "\\usepackage[hang,small,bf]{caption}",
      "\\usepackage[subrefformat=parens]{subcaption}",
    })
  ),
}
