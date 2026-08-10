-- 统一「执行当前东西」键：<leader><CR>
--
-- 用 Snacks.keymap 的 ft 选项把同一个键在不同 filetype 下分派到不同动作。
-- 文件名以 u 开头，字母序排在 snacks.lua 之后，因此加载时 Snacks 全局已存在。
--
-- 注意 Snacks.keymap 的两个特性（见 snacks/keymap.lua）：
--   1. by_ft[ft][key] 是覆盖写入 —— 同一 filetype 上同一个键只能有一条，
--      不像 lsp 分支那样有「多条候选按 enabled 逐个试」的优先级解析。
--      所以 neotest/dap 这种在同一批 filetype 上重叠的，必须在 rhs 里动态分派。
--   2. enabled 只在 buffer 打开时（FileType 事件）求值一次，不是按键时求值。
--      因此「有没有 dap session」这类动态判断也只能写在 rhs 里。

if not _G.Snacks then
  vim.notify('[unified-run] Snacks 未加载，跳过 <leader><CR> 映射', vim.log.levels.WARN)
  return
end

local KEY = '<leader><CR>'

--- SQL：走 vim-dadbod-ui 的 <Plug>(DBUI_ExecuteQuery)。
--- 该 plug 映射只在 DBUI 建立过的 query buffer 里存在，所以先探测再决定回退路径。
---@param visual boolean
local function run_sql(visual)
  if vim.fn.maparg('<Plug>(DBUI_ExecuteQuery)', visual and 'v' or 'n') ~= '' then
    return vim.api.nvim_feedkeys(vim.keycode '<Plug>(DBUI_ExecuteQuery)', 'm', false)
  end
  -- 不是 DBUI 的 query buffer：需要先选连接
  if vim.b.db or vim.g.db then
    vim.cmd(visual and "'<,'>DB" or '%DB')
  else
    vim.notify('[unified-run] 没有数据库连接，先 <leader>ud 打开 DBUI 或设置 b:db', vim.log.levels.WARN)
  end
end

-- 判断当前文件是否是测试文件，决定 <leader><CR> 走 neotest 还是 dap。
-- 用文件名约定而不是问 neotest 要 position tree：后者需要先解析 buffer，
-- 首次调用有明显延迟，且各 adapter 行为不一致。
local TEST_PATTERNS = {
  '^test_.*%.py$',
  '_test%.py$',
  '_test%.go$',
  'Test%.java$',
  'Tests%.java$',
  '%.test%.[jt]sx?$',
  '%.spec%.[jt]sx?$',
  '_spec%.rb$',
  '_test%.rb$',
  '_spec%.lua$',
  '_test%.exs$',
}

local function is_test_file()
  local name = vim.fn.expand '%:t'
  for _, pat in ipairs(TEST_PATTERNS) do
    if name:match(pat) then return true end
  end
  return false
end

--- 非测试文件：起/继续 dap（逻辑与 <leader>dr 一致）
local function run_dap()
  local dap = require 'dap'
  if dap.session() then return dap.continue() end
  if vim.bo.filetype == 'java' then
    require('custom.java-dap').launch(false)
  else
    dap.continue()
  end
end

local function run_code()
  if is_test_file() then
    require('neotest').run.run()
  else
    run_dap()
  end
end

-- ── 注册 ────────────────────────────────────────────────────────────────────

-- SQL：dadbod 执行查询（normal = 整个文件，visual = 选中片段）
Snacks.keymap.set('n', KEY, function() run_sql(false) end, { ft = { 'sql', 'mysql', 'plsql' }, desc = 'Run: SQL query' })
Snacks.keymap.set('x', KEY, function() run_sql(true) end, { ft = { 'sql', 'mysql', 'plsql' }, desc = 'Run: SQL selection' })

-- HTTP：rest.nvim 发送光标处的请求
Snacks.keymap.set('n', KEY, '<Cmd>Rest run<CR>', { ft = 'http', desc = 'Run: HTTP request' })

-- 代码文件：测试文件 → neotest 跑光标处，其余 → dap
Snacks.keymap.set('n', KEY, run_code, {
  ft = {
    'python',
    'java',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'go',
    'rust',
    'lua',
    'c',
    'cpp',
    'ruby',
  },
  desc = 'Run: test at cursor / debug',
})
