vim.g.mapleader = " "

require("core.lazy")
require("options")
-- share clipboard with OS
vim.opt.clipboard:append('unnamedplus,unnamed')

-- enable setting for each project
vim.opt.exrc = true
vim.opt.secure = true

vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'


-- augroup for this config file

local augroup = vim.api.nvim_create_augroup('init.lua', {})

-- wrapper function to use internal augroup
local function create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', {
    group = augroup
  }, opts))
end

-- https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(event)
    local dir = vim.fs.dirname(event.file)
    local force = vim.v.cmdbang == 1
    if vim.fn.isdirectory(dir) == 0
        and (force or vim.fn.confirm('"' .. dir .. '" does not exist. Create?', "&Yes\n&NO") == 1) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.opt.termencoding:get()), 'p')
    end
  end,
  desc = 'Auto mkdir to save file'
})

require("core.keymaps")
vim.keymap.set('n', 'p', 'p`]', { desc = 'Paste and move to the end' })
vim.keymap.set('n', 'P', 'P`]', { desc = 'Paste and move to the end' })
vim.keymap.set('x', 'p', 'P', { desc = 'Paste without change register' })
vim.keymap.set('x', 'P', 'p', { desc = 'Paste with change register' })
vim.keymap.set({ 'n', 'x' }, 'x', '"_d', { desc = 'Delete using blackhole register' })
vim.keymap.set('n', 'X', '"_D', { desc = 'Delete using blackhole register' })
vim.keymap.set('o', 'x', 'd', { desc = 'Delete using x' })
