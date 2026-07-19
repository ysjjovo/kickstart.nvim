-- toggleterm.nvim: multiple terminal management
-- https://github.com/akinsho/toggleterm.nvim

vim.pack.add {
  'https://github.com/akinsho/toggleterm.nvim',
}

require('toggleterm').setup {
  -- open_mapping = [[<C-\>]],
  direction = 'float', -- 默认改为浮动窗口
  -- persist_mode = false, -- 每次打开都进入 insert 模式，不记住上次的模式
  float_opts = {
    border = 'rounded', -- 浮动窗口使用圆角边框
  },
}

-- Alt+f/v/s 按方向打开 terminal
local function switch_direction(dir)
  local term = require('toggleterm.terminal').get(1)
  if term and term:is_open() then
    term:close()
    term.direction = dir
    term:open()
  else
    vim.cmd('ToggleTerm direction=' .. dir)
  end
end

vim.keymap.set('n', '<C-`>', function()
  vim.cmd(vim.v.count1 .. 'ToggleTerm')
end, { desc = 'Toggle Terminal' })
vim.keymap.set({ 'n', 't' }, '<A-f>', function() switch_direction('float') end, { desc = 'Terminal [F]loat' })
vim.keymap.set({ 'n', 't' }, '<A-v>', function() switch_direction('vertical') end, { desc = 'Terminal [V]ertical' })
vim.keymap.set({ 'n', 't' }, '<A-s>', function() switch_direction('horizontal') end, { desc = 'Terminal horizontal [S]plit' })

-- Normal 模式按 q 关闭 terminal
-- 窗口切换 <C-hjkl> 已在 init.lua 里全局绑定 normal + terminal 模式，这里不用再重复绑定。
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(ev)
    local bufname = vim.api.nvim_buf_get_name(ev.buf)
    if not bufname:match 'toggleterm' then
      return
    end
    -- vim.cmd 'startinsert'
    vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { buffer = ev.buf, nowait = true, desc = 'Exit terminal mode' })
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = ev.buf, nowait = true, desc = 'Terminal [q]uit' })
  end,
})

