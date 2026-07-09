-- debug.lua

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

-- vim.keymap.set('n', '<F8>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F9>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<leader>dd', function() require('dap').continue() end, { desc = 'Debug: Start/Resume' })
-- Terminate the running session (kills the debuggee / stops the run)
vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Debug: Terminate session' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })
--vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })

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
    -- Only 'repl' here: with console='internalConsole', program output goes through
    -- DAP output events into the repl (not the dapui 'console' element, which only
    -- shows integratedTerminal output and stays empty in our setup). repl is also
    -- useful in debug mode for evaluating expressions at breakpoints.
    { elements = { 'repl' }, size = 0.25, position = 'bottom' },
  },
}

-- Breakpoint icons and colors
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop',  { fg = '#ffcc00' })
vim.fn.sign_define('DapBreakpoint',          { text = '\xef\x86\x88', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointCondition', { text = '⊜', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapBreakpointRejected',  { text = '⊘', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapLogPoint',            { text = '◆', texthl = 'DapBreak', numhl = 'DapBreak' })
vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DapStop',  numhl = 'DapStop'  })

-- 会话启动时打开 dapui（调试 <leader>dd 和纯 run <leader>dr 都开）。
-- 说明：dapui 会把 dap 的 integratedTerminal 覆写成"只建 buffer 不开窗"，程序输出
-- 只能通过 dapui 的 console 面板显示。只开单个 layout 时 console 不会可靠地渲染出
-- 程序输出（时序/渲染问题），所以这里统一开完整 dapui —— run 模式下日志在底部
-- console 面板里能稳定看到。看完用 <leader>du 关闭面板即可。
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
-- 会话结束时关闭 dapui —— 但 noDebug（纯 run）例外：run 的程序往往瞬间跑完就退出，
-- 若自动关会把刚显示的日志一起关掉（表现为"没反应"，其实 <leader>du 还能调出）。
-- 所以 run 模式退出后保留面板，日志留给你看；看完手动 <leader>du 关。
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
--   * console: 由 setup_dap 的 config_overrides 统一设为 internalConsole（见 ftplugin/java.lua），
--     避免 integratedTerminal 的 runInTerminal 握手超时。
--   * 环境变量: 不在配置里设，由进程环境继承——dotenv 插件在进入项目目录时把 .env 加载进
--     nvim 进程环境，debuggee 自动继承。所以自动发现的配置开箱即用，无需 per-config env。
-- 触发：光标停在 .java 文件里 → <leader>dd（dap.continue）直接跑（单个 main 时不弹选择器）。

-- <leader>dr  纯 run（noDebug=true）：不挂断点，直接跑当前文件 main 到结束。
-- 比 <leader>dd（调试）体验更轻，也比终端 mvn exec:java 快（复用 jdtls 已编译的 class）。
-- 注意：启动主要开销在 jdtls 解析 classpath，run/debug 都要做，所以提速有限。
--
-- 这里【主动】打开 dapui，不依赖 event_initialized 监听器：noDebug 模式下 java-debug
-- 不走完整调试握手、可能不发 initialized 事件，靠事件开 UI 会失败（这正是之前
-- <leader>dd 能弹 UI、<leader>dr 弹不出来的原因）。先开 dapui 让 console 元素就位，
-- 程序 stdout 才有地方显示；再 run。
vim.keymap.set('n', '<leader>dr', function()
  -- dap.configurations.java is populated asynchronously by jdtls discovery
  -- (setup_dap_main_class_configs in ftplugin/java.lua). If it hasn't finished
  -- (or the buffer isn't a jdtls-analyzed main), there's nothing to run.
  local cfg = (dap.configurations.java or {})[1]
  if not cfg then
    vim.notify('No Java run config yet — wait for jdtls to attach/discover, then retry', vim.log.levels.WARN)
    return
  end
  require('dapui').open()
  require('dap').run(vim.tbl_extend('force', cfg, { noDebug = true }))
end, { desc = 'Debug: [R]un current file' })
