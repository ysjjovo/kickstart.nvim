-- vim-dadbod: database client for Neovim
-- Supports PostgreSQL, MySQL, SQLite, MongoDB, Redis, etc.

vim.pack.add {
  'https://github.com/tpope/vim-dadbod',
  'https://github.com/kristijanhusak/vim-dadbod-ui',
  'https://github.com/kristijanhusak/vim-dadbod-completion',
}

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
vim.g.db_ui_winwidth = 50
vim.g.db_ui_auto_execute_table_helpers = 1

-- Keymaps: <leader>d prefix for database operations
vim.keymap.set('n', '<leader>du', '<Cmd>DBUIToggle<CR>', { desc = '[D]atabase [U]I toggle' })
vim.keymap.set('n', '<leader>df', '<Cmd>DBUIFindBuffer<CR>', { desc = '[D]atabase [F]ind buffer' })
vim.keymap.set('n', '<leader>da', '<Cmd>DBUIAddConnection<CR>', { desc = '[D]atabase [A]dd connection' })
vim.keymap.set('n', '<leader>dl', '<Cmd>DBUILastQueryInfo<CR>', { desc = '[D]atabase [L]ast query info' })
