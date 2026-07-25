local M = {}

-- 启动当前 Java 文件的 main class
-- no_debug=true 时只运行不调试
function M.launch(no_debug)
  local dap = require 'dap'
  local bufnr = vim.api.nvim_get_current_buf()
  local classname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t:r')

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 30, false)
  local fqcn = classname
  for _, line in ipairs(lines) do
    local pkg = line:match '^%s*package%s+([%w%.]+)%s*;'
    if pkg then
      fqcn = pkg .. '.' .. classname
      break
    end
  end

  local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'jdtls' }
  if #clients == 0 then
    vim.notify('jdtls not attached — wait for LSP ready', vim.log.levels.WARN)
    return
  end
  if not dap.adapters.java then
    require('jdtls').setup_dap { hotcodereplace = 'auto' }
  end

  require('dapui').open()

  -- 持续显示启动状态，直到第一行输出
  local msg = (no_debug and 'Running ' or 'Debugging ') .. fqcn .. '…'
  local timer = vim.uv.new_timer()
  local dots = 0
  timer:start(0, 800, vim.schedule_wrap(function()
    dots = (dots + 1) % 4
    vim.api.nvim_echo({ { msg .. string.rep('.', dots), 'DiagnosticInfo' } }, false, {})
  end))
  local function stop_timer()
    if timer and timer:is_active() then timer:stop() timer:close() end
    vim.api.nvim_echo({ { '' } }, false, {})
  end
  dap.listeners.before.event_output['startup_notify'] = function()
    stop_timer()
    dap.listeners.before.event_output['startup_notify'] = nil
  end
  dap.listeners.before.event_terminated['startup_notify'] = function()
    stop_timer()
    dap.listeners.before.event_terminated['startup_notify'] = nil
  end

  dap.run {
    type = 'java',
    request = 'launch',
    name = (no_debug and 'Run ' or 'Debug ') .. fqcn,
    mainClass = fqcn,
    cwd = clients[1].config.root_dir,
    console = 'internalConsole',
    shortenCommandLine = 'argfile',
    noDebug = no_debug or nil,
    -- 加速 JVM 启动：跳过 C2 编译，禁用字节码验证
    vmArgs = '-XX:TieredStopAtLevel=1 -noverify',
  }
end

return M
