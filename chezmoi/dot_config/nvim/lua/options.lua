local opt = vim.opt

-- number of lines
opt.number = true
opt.relativenumber = true

-- indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- display
opt.termguicolors = true
opt.wrap = false
opt.scrolloff = 8
opt.signcolumn = "yes"

-- edit
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.updatetime = 300

-- conceal
opt.conceallevel = 2

-- turn
opt.wrap = true
opt.breakindent = true
opt.showbreak = string.rep(" ", 3)
opt.linebreak = true

-- transparent
opt.termguicolors = true
opt.winblend = 0
opt.pumblend = 0
