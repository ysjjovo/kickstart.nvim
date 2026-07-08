-- neotest: 测试运行框架，支持光标处跑方法、类跑整组、dap 调试
-- https://github.com/nvim-neotest/neotest

vim.pack.add {
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/nvim-neotest/nvim-nio', -- neotest 依赖（debug.lua 已装，幂等）
  'https://github.com/nvim-neotest/neotest-python',
  'https://github.com/rcasia/neotest-java', -- Java 适配器，依赖 jdtls（见 ftplugin/java.lua）
}

local function find_python()
  local path = vim.fn.expand '%:p:h'
  while path ~= '/' do
    local venv = path .. '/.venv/bin/python'
    if vim.fn.executable(venv) == 1 then return venv end
    path = vim.fn.fnamemodify(path, ':h')
  end
  return vim.fn.exepath 'python3'
end

require('neotest').setup {
  adapters = {
    require 'neotest-python' {
      dap = { justMyCode = false },
      runner = 'pytest',
      python = find_python,
    },
    -- Java：默认配置即可，自动探测 Maven/Gradle。
    -- 依赖 jdtls 已附着（ftplugin/java.lua）+ java-debug/java-test bundle。
    -- 首次使用需 :NeotestJava setup 下载 JUnit runner，并 :TSInstall java。
    require 'neotest-java' {},
  },
}

local nt = require 'neotest'

-- <leader>tr  光标处的方法（最常用）
vim.keymap.set('n', '<leader>tr', function() nt.run.run() end, { desc = '[T]est [R]un nearest' })

-- <leader>tf  当前文件 / 光标在类名上时跑整个类
vim.keymap.set('n', '<leader>tf', function() nt.run.run(vim.fn.expand '%') end, { desc = '[T]est run [F]ile' })

-- <leader>td  以 dap 模式调试光标处的方法（需要 venv 装了 debugpy）
vim.keymap.set('n', '<leader>td', function() nt.run.run { strategy = 'dap' } end, { desc = '[T]est [D]ebug nearest' })

-- <leader>ts  切换测试结果面板
vim.keymap.set('n', '<leader>ts', function() nt.summary.toggle() end, { desc = '[T]est [S]ummary toggle' })

-- <leader>to  打开最近一次测试输出
vim.keymap.set('n', '<leader>to', function() nt.output.open { enter = true } end, { desc = '[T]est [O]utput open' })
