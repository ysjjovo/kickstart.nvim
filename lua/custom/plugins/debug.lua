vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
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
-- 不在这里手写 dap.configurations.java。配置完全由 jdtls 自动发现：
-- ftplugin/java.lua 的 on_attach 里 setup_dap{...} 注册适配器，
-- setup_dap_main_class_configs() 扫描项目 main class 生成 launch 配置。

-- <leader>dr  纯 run（noDebug=true）
vim.keymap.set('n', '<leader>dr', function()
  local cfg = (dap.configurations.java or {})[1]
  if not cfg then
    vim.notify('No Java run config yet — wait for jdtls to attach/discover, then retry', vim.log.levels.WARN)
    return
  end
  require('dapui').open()
  require('dap').run(vim.tbl_extend('force', cfg, { noDebug = true }))
end, { desc = 'Debug: [R]un current file' })
