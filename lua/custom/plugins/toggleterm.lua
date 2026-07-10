-- toggleterm.nvim: multiple terminal management
-- https://github.com/akinsho/toggleterm.nvim

vim.pack.add {
  'https://github.com/akinsho/toggleterm.nvim',
}

require('toggleterm').setup {
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    end
  end,
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  persist_size = true,
  direction = 'float',
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = 'rounded',
    winblend = 0,
  },
}

-- Alt+1/2/3 切换编号 terminal（浮动窗口）
vim.keymap.set({ 'n', 't' }, '<A-1>', '<Cmd>1ToggleTerm direction=float<CR>', { desc = 'Terminal [1]' })
vim.keymap.set({ 'n', 't' }, '<A-2>', '<Cmd>2ToggleTerm direction=float<CR>', { desc = 'Terminal [2]' })
vim.keymap.set({ 'n', 't' }, '<A-3>', '<Cmd>3ToggleTerm direction=float<CR>', { desc = 'Terminal [3]' })
vim.keymap.set({ 'n'}, 't', '<Cmd>ToggleTerm<CR>', { desc = 'Toogle Terminal' })

-- Alt+f/v/s 按方向打开 terminal
-- vim.keymap.set({ 'n', 't' }, '<A-f>', '<Cmd>ToggleTerm direction=float<CR>', { desc = 'Terminal [F]loat' })
vim.keymap.set({ 'n', 't' }, '<A-v>', '<Cmd>ToggleTerm direction=vertical<CR>', { desc = 'Terminal [V]ertical' })
vim.keymap.set({ 'n', 't' }, '<A-s>', '<Cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Terminal horizontal [S]plit' })

-- Normal 模式按 q 关闭 terminal
-- 窗口切换 <C-hjkl> 已在 init.lua 里全局绑定 normal + terminal 模式，这里不用再重复绑定。
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = function(ev)
    vim.keymap.set('n', 'q', '<Cmd>ToggleTerm<CR>', { buffer = ev.buf, nowait = true, desc = 'Terminal [q]uit' })
  end,
})
