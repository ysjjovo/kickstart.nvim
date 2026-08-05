vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
}

vim.keymap.set('n', '<F9>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set [C]onditional breakpoint' })
vim.keymap.set('n', '<leader>dr', function()
  local dap_mod = require 'dap'
  if dap_mod.session() then
    dap_mod.continue()
    return
  end
  if vim.bo.filetype == 'java' then
    require('custom.java-dap').launch(false)
  else
    dap_mod.continue()
  end
end, { desc = 'Debug: [S]tart/Resume' })
vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Debug: [T]erminate session' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle [U]I' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason').setup {}

require('mason-nvim-dap').setup {
  automatic_installation = true,
  handlers = {},
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

vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
vim.fn.sign_define('DapBreakpoint', { text = '\xef\x86\x88', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointCondition', { text = '⊜', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointRejected', { text = '⊘', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStop', numhl = 'DapStop' })

-- 跳转前重新加载 buffer，防止行号超出范围导致光标不跟随
dap.listeners.before.event_stopped['cursor_follow'] = function()
  vim.cmd 'checktime'
end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open

-- 加载语言配置（dap/*.lua），删除文件即移除该语言支持
local dap_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins', 'dap')
for name, type in vim.fs.dir(dap_dir) do
  if type == 'file' and name:match '%.lua$' then
    local mod = name:gsub('%.lua$', '')
    local ok, err = pcall(require, 'custom.plugins.dap.' .. mod)
    if not ok then
      vim.notify('[dap] Failed to load dap/' .. name .. ':\n' .. err, vim.log.levels.WARN)
    end
  end
end
