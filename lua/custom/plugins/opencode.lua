-- opencode.nvim: Neovim <-> OpenCode API 集成
-- 通过 API 通信，自动传递文件路径、行号等编辑器上下文

require 'custom.plugins.snacks'

vim.pack.add {
  {
    src = 'https://github.com/nickjvandyke/opencode.nvim',
    version = vim.version.range '*',
  },
}

local opencode_cmd = 'opencode --port'
local snacks_terminal_opts = {
  win = {
    position = 'right',
    width = 0.4,
    enter = false,
  },
}

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = function()
      require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
    end,
  },
}

-- 聚焦到 opencode 终端（未启动则自动启动）
local function focus_opencode()
  require('snacks.terminal').open(opencode_cmd, vim.tbl_deep_extend('force', snacks_terminal_opts, {
    win = { enter = true },
  }))
end

-- 快捷键：<leader>a 前缀
vim.keymap.set({ 'n', 'x' }, '<leader>aa', function()
  require('opencode').ask('@this: ')
  focus_opencode()
end, { desc = 'OpenCode [A]sk' })

vim.keymap.set({ 'n', 'x' }, '<leader>as', function()
  require('opencode').select()
  focus_opencode()
end, { desc = 'OpenCode [S]elect prompt' })

vim.keymap.set({ 'n', 't' }, '<leader>af', focus_opencode, { desc = 'OpenCode [F]ocus' })

vim.keymap.set({ 'n', 'x' }, '<leader>as', function()
  return require('opencode').operator('@this ')
end, { desc = 'OpenCode operator [S]end', expr = true })

vim.keymap.set('n', '<leader>ass', function()
  return require('opencode').operator('@this ') .. '_'
end, { desc = 'OpenCode operator [S]end line', expr = true })

-- TUI 终端切换
vim.keymap.set({ 'n', 't' }, '<leader>au', function()
  require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
end, { desc = 'OpenCode toggle [U]I' })

-- 滚动 OpenCode 会话
vim.keymap.set('n', '<leader>aj', function()
  require('opencode').command('session.half.page.down')
end, { desc = 'OpenCode scroll down' })

vim.keymap.set('n', '<leader>ak', function()
  require('opencode').command('session.half.page.up')
end, { desc = 'OpenCode scroll up' })
