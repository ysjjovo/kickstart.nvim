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

-- <leader>t prefix for terminal operations
vim.keymap.set('n', '<leader>tt', '<Cmd>ToggleTerm direction=float<CR>', { desc = '[T]erminal float [T]oggle' })
vim.keymap.set('n', '<leader>th', '<Cmd>ToggleTerm direction=horizontal<CR>', { desc = '[T]erminal [H]orizontal' })
vim.keymap.set('n', '<leader>tv', '<Cmd>ToggleTerm direction=vertical<CR>', { desc = '[T]erminal [V]ertical' })

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
    vim.cmd('startinsert')
  end,
})
-- 切换编号 terminal
vim.keymap.set('n', '<leader>t1', '<Cmd>1ToggleTerm<CR>', { desc = '[T]erminal [1]' })
vim.keymap.set('n', '<leader>t2', '<Cmd>2ToggleTerm<CR>', { desc = '[T]erminal [2]' })
vim.keymap.set('n', '<leader>t3', '<Cmd>3ToggleTerm<CR>', { desc = '[T]erminal [3]' })

-- lazygit 专用 terminal
local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new {
  cmd = 'lazygit',
  dir = 'git_dir',
  direction = 'float',
  float_opts = {
    border = 'rounded',
  },
  on_open = function(term)
    vim.cmd 'startinsert!'
  end,
}
vim.keymap.set('n', '<leader>tg', function() lazygit:toggle() end, { desc = '[T]erminal Lazygit' })
