vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

vim.keymap.set('n', '<F9>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<leader>dd', function() require('dap').continue() end, { desc = 'Debug: Start/Resume' })
vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Debug: Terminate session' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason').setup {}

require('mason-nvim-dap').setup {
  automatic_installation = true,
  handlers = {},
  ensure_installed = {
    'delve',
    'js-debug-adapter',
    'debugpy',
    'java-debug-adapter',
    'java-test',
  },
}

---@diagnostic disable-next-line: missing-fields
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸', play = '▶', step_into = '⏎', step_over = '⏭',
      step_out = '⏮', step_back = 'b', run_last = '▶▶', terminate = '⏹', disconnect = '⏏',
    },
  },
  layouts = {
    { elements = { 'scopes', 'breakpoints', 'stacks', 'watches' }, size = 60, position = 'left' },
    { elements = { 'repl' }, size = 0.25, position = 'bottom' },
  },
}

require('nvim-dap-virtual-text').setup {}

-- Breakpoint icons and colors
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
vim.fn.sign_define('DapBreakpoint', { text = '\xef\x86\x88', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointCondition', { text = '⊜', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointRejected', { text = '⊘', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStop', numhl = 'DapStop' })

-- 会话启动时打开 dapui
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
-- 会话结束时关闭 dapui（noDebug 模式保留面板方便查看输出）
local function close_dapui_unless_run(session)
  if not (session and session.config and session.config.noDebug) then
    dapui.close()
  end
end
dap.listeners.before.event_terminated['dapui_config'] = close_dapui_unless_run
dap.listeners.before.event_exited['dapui_config'] = close_dapui_unless_run

-- JavaScript / Jest
local js_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = { command = 'node', args = { js_debug_path, '${port}' } },
}
dap.configurations.javascript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Jest: current file',
    runtimeExecutable = 'npx',
    runtimeArgs = { 'jest', '--testPathPattern', '${fileBasenameNoExtension}', '--no-coverage', '--runInBand' },
    cwd = '${workspaceFolder}',
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
  },
}

-- Go
require('dap-go').setup {
  delve = { detached = vim.fn.has 'win32' == 0 },
}

-- Java (jdtls + java-debug-adapter)
-- ftplugin/java.lua 的 on_attach 里 setup_dap{...} 注册 DAP 适配器。
-- <leader>dd 调试时通过 lazy provider 自动发现 main class；
-- <leader>dr 直接从当前文件解析 FQCN 启动运行。

-- <leader>dr  运行当前 Java 文件的 main class（noDebug=true）
vim.keymap.set('n', '<leader>dr', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local classname = vim.fn.fnamemodify(filepath, ':t:r')

  -- 从 buffer 中解析 package 声明，拼出 FQCN
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
  local root_dir = clients[1].config.root_dir
  local project_name = vim.fn.fnamemodify(root_dir, ':t')

  require('dapui').open()
  dap.run {
    type = 'java',
    request = 'launch',
    name = 'Run ' .. fqcn,
    mainClass = fqcn,
    projectName = project_name,
    cwd = root_dir,
    console = 'integratedTerminal',
    noDebug = true,
  }
end, { desc = 'Debug: [R]un current file' })
