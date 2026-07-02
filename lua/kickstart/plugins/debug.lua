-- debug.lua

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

vim.keymap.set('n', '<F8>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F9>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  automatic_installation = true,
  handlers = {},
  ensure_installed = {
    'delve',
    'js-debug-adapter',
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
    { elements = { 'repl', 'console' }, size = 0.25, position = 'bottom' },
  },
}

-- Breakpoint icons and colors
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop',  { fg = '#ffcc00' })
vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointCondition', { text = '⊜', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointRejected',  { text = '⊘', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapLogPoint',            { text = '◆', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DapStop',  numhl = 'DapStop'  })

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

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
