-- hardtime.nvim: break bad habits, learn efficient motions
vim.pack.add { 'https://github.com/m4xshen/hardtime.nvim' }

require('hardtime').setup {
  -- 允许连按的最大次数，超过则提示
  max_count = 3,
  disabled_filetypes = { 'qf', 'oil', 'lazy', 'mason', 'help', 'dashboard' },
}

vim.keymap.set('n', '<leader>huh', '<cmd>Hardtime toggle<CR>', { desc = 'Toggle Hardtime' })
-- vim.keymap.set('n', '<leader>hr', '<cmd>Hardtime report<CR>', { desc = 'Hardtime Report' })
