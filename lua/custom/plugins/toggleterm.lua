-- toggleterm.nvim: multiple terminal management
-- https://github.com/akinsho/toggleterm.nvim

vim.pack.add {
  'https://github.com/akinsho/toggleterm.nvim',
}

require('toggleterm').setup {
  start_in_insert = true,
  direction = 'float', -- 默认改为浮动窗口
  float_opts = {
    border = 'rounded', -- 浮动窗口使用圆角边框
  },
  open_mapping = [[t]]
}

-- vim.keymap.set({ 'n'}, 't', '<Cmd>ToggleTerm<CR>', { desc = 'Toogle Terminal' })

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

vim.keymap.set({ 'n', 't' }, '<A-f>', function() switch_direction('float') end, { desc = 'Terminal [F]loat' })
vim.keymap.set({ 'n', 't' }, '<A-v>', function() switch_direction('vertical') end, { desc = 'Terminal [V]ertical' })
vim.keymap.set({ 'n', 't' }, '<A-s>', function() switch_direction('horizontal') end, { desc = 'Terminal horizontal [S]plit' })

-- Normal 模式按 q 关闭 terminal
-- 窗口切换 <C-hjkl> 已在 init.lua 里全局绑定 normal + terminal 模式，这里不用再重复绑定。
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(ev)
    vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
    vim.keymap.set('n', 'q', '<Cmd>ToggleTerm<CR>', { buffer = ev.buf, nowait = true, desc = 'Terminal [q]uit' })
  end,
})
