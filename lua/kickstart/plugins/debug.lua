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
    { elements = { 'repl', 'console' }, size = 0.25, position = 'bottom' },
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
-- 适配器 dap.adapters.java 在 ftplugin/java.lua 的 on_attach 里通过
-- require('jdtls').setup_dap{} 注册（必须等 jdtls attach 后才能注册）。
-- 这里只放【通用】launch 配置，不写死任何具体项目：
--   * mainClass 留空 → java-debug 从当前 buffer 解析出 main class
--   * classPaths / modulePaths / javaExec / projectName 由适配器 enrich_config 自动补齐
--   * 环境变量走 envFile：运行时从当前文件所在目录向上找最近的 .env（dotenv 格式 KEY=VALUE）
--     —— 需要环境变量的项目（如 mediacdn-log-func）只需在模块根放一个 .env 即可，
--        不需要的项目找不到 .env 就当没有，互不影响。
--
-- 触发：光标停在 .java 文件里 → <leader>dd（dap.continue）→ 选 "Java: 运行当前文件 main"。
-- 除此之外，jdtls 还会自动发现项目里所有 main class 生成额外条目（那些不读 .env）。
-- 注意：不能用 launch config 的 `envFile` 字段。envFile 是 VSCode java-debug【前端扩展】
-- 在 resolveDebugConfiguration 阶段读文件、合并进 env 后才发给调试服务器的；而 nvim-jdtls
-- 直连调试服务器（vscode.java.startDebugSession），绕过前端，envFile 无人处理会静默失效。
-- 调试服务器只认 `env`（一个 map）。所以这里自己读 .env、解析成 table 喂给 env。
local function nearest_env_table()
  -- 从当前 buffer 文件所在目录向上查找最近的 .env
  local start = vim.fn.expand '%:p:h'
  local path = vim.fs.find('.env', { path = start, upward = true, type = 'file' })[1]
  if not path then
    return nil -- 找不到就不设 env，不影响其它项目
  end
  local env = {}
  for line in io.lines(path) do
    line = vim.trim(line)
    -- 跳过空行和注释（# 开头）
    if line ~= '' and not vim.startswith(line, '#') then
      local key, val = line:match '^([^=]+)=(.*)$'
      if key then
        -- 去掉 key/val 两端空白，以及 val 可能的成对引号
        key = vim.trim(key)
        val = vim.trim(val):gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')
        env[key] = val
      end
    end
  end
  return env
end

dap.configurations.java = {
  {
    name = 'Java: Current file main',
    type = 'java',
    request = 'launch',
    -- 不要设 mainClass=''：Lua 里空串是 truthy，会让适配器 enrich_config 里的
    -- `if not config.mainClass` 判断为假，从而跳过 resolve_classname()，
    -- 导致 mainClass 一直是空串、classPaths 解析不出来 → "Missing mainClass" 报错。
    -- 省略此字段（nil）才会触发从当前 buffer 自动解析出类名。
    --
    -- console 用 internalConsole，不要用 integratedTerminal：
    -- integratedTerminal 模式下 java-debug 会发 runInTerminal 反向请求，要求前端在
    -- 终端里起进程；nvim-dap + dapui 把终端重定向成"只建 buffer 不开窗"，这个握手会
    -- 超时（报 "Failed to launch debuggee in terminal: TimeoutException"，java-debug
    -- 官方文档也把切到 internalConsole 列为该超时的解法）。internalConsole 让程序输出
    -- 走 DAP 的 output 事件，直接显示在 dapui 的 repl 面板，不走终端、不会超时。
    -- 代价：internalConsole 不支持 stdin，但本地跑 main 不需要输入，无所谓。
    console = 'internalConsole',
    -- 函数值会被 nvim-dap 在启动时求值（见 dap.lua eval_option）；
    -- 返回 nil 时该字段视为未设置。
    env = nearest_env_table,
  },
}

-- <leader>dr  纯 run（noDebug=true）：不挂断点，直接跑当前文件 main 到结束。
-- 比 <leader>dd（调试）体验更轻，也比终端 mvn exec:java 快（复用 jdtls 已编译的 class）。
-- 注意：启动主要开销在 jdtls 解析 classpath，run/debug 都要做，所以提速有限。
--
-- 这里【主动】打开 dapui，不依赖 event_initialized 监听器：noDebug 模式下 java-debug
-- 不走完整调试握手、可能不发 initialized 事件，靠事件开 UI 会失败（这正是之前
-- <leader>dd 能弹 UI、<leader>dr 弹不出来的原因）。先开 dapui 让 console 元素就位，
-- 程序 stdout 才有地方显示；再 run。
vim.keymap.set('n', '<leader>dr', function()
  require('dapui').open()
  require('dap').run(vim.tbl_extend('force', dap.configurations.java[1], { noDebug = true }))
end, { desc = 'Debug: [R]un current file' })
