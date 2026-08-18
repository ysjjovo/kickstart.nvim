-- opencode.nvim: neovim <-> opencode api 集成
-- 通过 API 通信，自动传递文件路径、行号等编辑器上下文

require 'custom.plugins.snacks'

vim.pack.add {
  {
    src = 'https://github.com/nickjvandyke/opencode.nvim',
    version = vim.version.range '*',
  },
}

-- 每个 nvim 实例独立端口，避免 discovery 连到其他实例
local opencode_port = 19000 + (vim.fn.getpid() % 10000)
local opencode_cmd = 'opencode --port ' .. opencode_port
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = 'right',
    width = 0.4,
    enter = false,
    keys = {
      -- 覆盖全局 snacks 终端的「单 Esc 即退出」映射：
      -- 单 Esc 透传给 opencode（响应其内部操作，如取消补全/清空输入）；
      -- 200ms 内连按两次 Esc 才 stopinsert 进入 normal，用于滚动查看会话。
      -- 用定时器判断双击，而非 <esc><esc> 映射，避免单 Esc 被 timeoutlen 卡住延迟送达。
      term_normal = {
        '<esc>',
        function(self)
          self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
          if self.esc_timer:is_active() then
            self.esc_timer:stop()
            vim.cmd 'stopinsert'
          else
            self.esc_timer:start(200, 0, function() end)
            return '<esc>'
          end
        end,
        mode = 't',
        expr = true,
        desc = 'Double escape to normal mode',
      },
    },
  },
}

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    url = 'http://localhost:' .. opencode_port,
    start = function()
      -- 用 get 而非 open：get 按 tid 去重，避免和 operator 的 focus 竞争
      -- 各自 open 一次，重复启动 opencode（同端口冲突 → 首次发送失效 + 双窗口）
      require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts)
    end,
  },
}

-- 不在发送期间抢焦点：Context 的 buffer 在 discovery 的异步回调里才捕获，
-- 若此时 focus 已进入终端窗口，@this 会拿到终端 buffer 而非源文件 → 渲染成空
-- prompt。聚焦统一放到下方 prompt.submit 事件里，那是发送完成后的确定时机。

-- operator 天然支持 visual 模式（g@ 作用于选区）
vim.keymap.set({ 'n', 'x' }, '<leader>as', function()
  return require('opencode').operator('@this ')
end, { desc = 'OpenCode [S]end', expr = true })

vim.keymap.set('n', '<leader>ass', function()
  return require('opencode').operator('@this ') .. '_'
end, { desc = 'OpenCode [S]end line', expr = true })

vim.keymap.set({ 'n', 'x' }, '<leader>aa', function()
  require('opencode').ask('@this: ')
end, { desc = 'OpenCode [A]sk' })

vim.keymap.set({ 'n', 'x' }, '<leader>ax', function()
  require('opencode').select()
end, { desc = 'OpenCode sele[X]t' })

-- 终端切换/聚焦
vim.keymap.set({ 'n', 't' }, '<leader>af', function()
  require('snacks.terminal').focus(opencode_cmd, snacks_terminal_opts)
end, { desc = 'OpenCode [F]ocus' })

vim.keymap.set({ 'n', 't' }, '<leader>au', function()
  require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
end, { desc = 'OpenCode toggle [U]I' })

-- 滚动 OpenCode 会话
-- vim.keymap.set('n', '<leader>aj', function()
--   require('opencode').command('session.half.page.down')
-- end, { desc = 'OpenCode scroll down' })
--
-- vim.keymap.set('n', '<leader>ak', function()
--   require('opencode').command('session.half.page.up')
-- end, { desc = 'OpenCode scroll up' })

-- nvim 退出时杀掉本实例的 opencode 进程
-- vim.api.nvim_create_autocmd('VimLeavePre', {
--   callback = function()
--     vim.fn.jobstart({ 'pkill', '-f', 'opencode --port ' .. opencode_port }, { detach = true })
--   end,
-- })
