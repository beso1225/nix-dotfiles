local M = {}

local function run(args)
  return vim.system(args, { text = true }):wait()
end

function M.open(pdf)
  pdf = vim.fn.fnamemodify(pdf, ':p')
  if vim.fn.filereadable(pdf) == 0 then
    vim.notify('tdf: PDF not found: ' .. pdf, vim.log.levels.WARN)
    return
  end

  local tex = vim.api.nvim_buf_get_name(0)
  local position = string.format('%d:%d:%s', vim.fn.line('.'), vim.fn.col('.'), tex)
  local stem = vim.fn.fnamemodify(pdf, ':t:r')
  local socket = '/tmp/tdf-' .. stem .. '.sock'

  if vim.uv.fs_stat(socket) then
    local forward = run({ 'tdf', '--synctex-forward', position, '--synctex-socket', socket })
    if forward.code == 0 then
      return
    end
  end

  if vim.fn.executable('herdr') == 0 or vim.fn.executable('tdf') == 0 then
    vim.notify('tdf: herdr and tdf must be on PATH', vim.log.levels.ERROR)
    return
  end

  local split = run({ 'herdr', 'pane', 'split', '--current', '--direction', 'right',
    '--cwd', vim.fn.fnamemodify(pdf, ':h'), '--env', 'NVIM=' .. vim.v.servername, '--no-focus' })
  if split.code ~= 0 then
    vim.notify('tdf: herdr split failed: ' .. (split.stderr or ''), vim.log.levels.ERROR)
    return
  end

  local ok, pane = pcall(vim.json.decode, split.stdout)
  local result = ok and (pane.result or pane)
  local id = result and (result.pane_id or result.new_pane_id or result.id
    or (result.pane and result.pane.pane_id))
  if not id then
    vim.notify('tdf: cannot read new herdr pane ID: ' .. split.stdout, vim.log.levels.ERROR)
    return
  end

  local command = 'tdf ' .. vim.fn.shellescape(pdf) .. ' --synctex-forward ' .. vim.fn.shellescape(position)
  local started = run({ 'herdr', 'pane', 'run', tostring(id), command })
  if started.code ~= 0 then
    vim.notify('tdf: could not start viewer: ' .. (started.stderr or ''), vim.log.levels.ERROR)
  end
end

return M
