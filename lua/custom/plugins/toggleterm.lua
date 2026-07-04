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

-- Alt+f/v/s 按方向打开 terminal
vim.keymap.set({ 'n', 't' }, '<A-f>', '<Cmd>ToggleTerm direction=float<CR>', { desc = 'Terminal [F]loat' })
vim.keymap.set({ 'n', 't' }, '<A-v>', '<Cmd>ToggleTerm direction=vertical<CR>', { desc = 'Terminal [V]ertical' })
vim.keymap.set({ 'n', 't' }, '<A-s>', '<Cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Terminal horizontal [S]plit' })

-- Exit terminal mode and navigate windows
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(ev)
    local buf = ev.buf
    local opts = { buffer = buf, nowait = true }
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>',       opts)
    vim.keymap.set('t', '<C-h>',      '<Cmd>wincmd h<CR>', opts)
    vim.keymap.set('t', '<C-j>',      '<Cmd>wincmd j<CR>', opts)
    vim.keymap.set('t', '<C-k>',      '<Cmd>wincmd k<CR>', opts)
    vim.keymap.set('t', '<C-l>',      '<Cmd>wincmd l<CR>', opts)
  end,
})

-- lazygit 已迁移到 lazygit.nvim 插件 (lazygit.lua)
-- 以下为原 toggleterm lazygit 配置，保留备用：
-- local Terminal = require('toggleterm.terminal').Terminal
-- local lazygit = Terminal:new {
--   cmd = 'lazygit',
--   dir = 'git_dir',
--   direction = 'float',
--   float_opts = {
--     border = 'rounded',
--   },
--   on_open = function(term)
--     vim.cmd 'startinsert!'
--   end,
-- }
-- vim.keymap.set('n', '<leader>tg', function() lazygit:toggle() end, { desc = '[T]erminal Lazygit' })
