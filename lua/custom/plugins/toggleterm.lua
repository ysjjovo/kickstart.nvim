-- toggleterm.nvim: persistent toggleable terminal windows
vim.pack.add { 'https://github.com/akinsho/toggleterm.nvim' }

require('toggleterm').setup {
  open_mapping = [[<C-\>]],
  direction = 'float',
  size = function(term)
    if term.direction == 'horizontal' then
      return math.floor(vim.o.lines * 0.35)
    elseif term.direction == 'vertical' then
      return math.floor(vim.o.columns * 0.45)
    end
  end,
  float_opts = { border = 'curved' },
  shade_terminals = false,
  start_in_insert = true,
  close_on_exit = true,
}

-- Specific layout variants
vim.keymap.set('n', '<leader>tf', '<Cmd>ToggleTerm direction=float<CR>',      { desc = '[T]erminal [F]loat' })
vim.keymap.set('n', '<leader>th', '<Cmd>ToggleTerm direction=horizontal<CR>', { desc = '[T]erminal [H]orizontal' })
vim.keymap.set('n', '<leader>tv', '<Cmd>ToggleTerm direction=vertical<CR>',   { desc = '[T]erminal [V]ertical' })

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

-- lazygit (if installed)
local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new {
  cmd = 'lazygit',
  direction = 'float',
  hidden = true,
  float_opts = { border = 'curved' },
}
vim.keymap.set('n', '<leader>tg', function() lazygit:toggle() end, { desc = '[T]erminal Lazygit' })
