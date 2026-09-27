local M = {}
local panes = {}

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

  local pane_id = panes[pdf]
  local pane_running = false
  if pane_id then
    local info = run({ 'herdr', 'pane', 'process-info', '--pane', pane_id })
    if info.code == 0 then
      local ok, response = pcall(vim.json.decode, info.stdout)
      local processes = ok and response.result and response.result.process_info
        and response.result.process_info.foreground_processes or {}
      for _, process in ipairs(processes) do
        if vim.fn.fnamemodify(process.argv[1] or '', ':t') == 'tdf' and process.argv[2] == pdf then
          pane_running = true
          break
        end
      end
    else
      panes[pdf] = nil
      pane_id = nil
    end
  end

  if pane_running then
    if vim.uv.fs_stat(socket) then
      local forward = run({ 'tdf', pdf, '--synctex-forward', position, '--synctex-socket', socket })
      if forward.code == 0 then
        return
      end
    end
    vim.notify('tdf: viewer is running but SyncTeX forwarding failed', vim.log.levels.WARN)
    return
  end

  if vim.fn.executable('herdr') == 0 or vim.fn.executable('tdf') == 0 then
    vim.notify('tdf: herdr and tdf must be on PATH', vim.log.levels.ERROR)
    return
  end

  if not pane_id then
    local split = run({ 'herdr', 'pane', 'split', '--current', '--direction', 'right',
      '--cwd', vim.fn.fnamemodify(pdf, ':h'), '--env', 'NVIM=' .. vim.v.servername, '--no-focus' })
    if split.code ~= 0 then
      vim.notify('tdf: herdr split failed: ' .. (split.stderr or ''), vim.log.levels.ERROR)
      return
    end

    local ok, pane = pcall(vim.json.decode, split.stdout)
    local result = ok and (pane.result or pane)
    pane_id = result and (result.pane_id or result.new_pane_id or result.id
      or (result.pane and result.pane.pane_id))
    if not pane_id then
      vim.notify('tdf: cannot read new herdr pane ID: ' .. split.stdout, vim.log.levels.ERROR)
      return
    end
    panes[pdf] = pane_id
  end

  local command = 'tdf ' .. vim.fn.shellescape(pdf) .. ' --synctex-forward ' .. vim.fn.shellescape(position)
  local started = run({ 'herdr', 'pane', 'run', tostring(pane_id), command })
  if started.code ~= 0 then
    panes[pdf] = nil
    vim.notify('tdf: could not start viewer: ' .. (started.stderr or ''), vim.log.levels.ERROR)
  end
end

return M
