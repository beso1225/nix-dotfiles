local map = vim.keymap.set

-- jj as escape in insert mode
map("i", "jk", "<esc>")

-- <cr> to insert a new line in normal mode
map("n", "<cr>", "o<esc>")
map("n", "<S-cr>", "O<esc>")

-- unhighlight search results
map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  vim.fn.setreg("/", "")
end)

-- <leader> + +/- to increment / decreent
vim.keymap.set({ 'n', 'v' }, '<leader>+', '<C-a>', { desc = 'Increment' })
vim.keymap.set({ 'n', 'v' }, '<leader>-', '<C-x>', { desc = 'Decrement' })

vim.keymap.set('v', 'g<leader>+', 'g<C-a>', { desc = 'Sequential increment' })
vim.keymap.set('v', 'g<leader>-', 'g<C-x>', { desc = 'Sequential decrement' })

-- for telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

-- for LSP
map("n", "gd", vim.lsp.buf.definition)

-- for lazygit
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
})

function _lazygit_toggle()
  lazygit:toggle()
end

map("n", "lg", "<cmd>lua _lazygit_toggle()<cr>", { noremap = true, silent = true })

-- for copilot
map("i", "<C-n>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })
vim.g.copilot_no_tab_map = true

-- for barbar
map("n", "<C-H>", "<Cmd>BufferPrevious<CR>", { noremap = true, silent = true })
map("n", "<C-L>", "<Cmd>BufferNext<CR>", { noremap = true, silent = true })
map("n", "<C-W>", "<Cmd>BufferClose<CR>", { noremap = true, silent = true })
