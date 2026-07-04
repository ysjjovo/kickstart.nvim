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
local wk = require 'which-key'

-- 1. Toggle the DBUI drawer from anywhere
wk.add {
  { '<leader>dd', '<cmd>DBUIToggle<CR>', desc = '[D]atabase Toggle UI' },
}

-- 2. 在 SQL 缓冲区里常用的操作（只在 SQL/dbout 文件中生效，保持 which-key 干净）
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'plsql', 'dbout' },
  callback = function(ev)
    wk.add {
      mode = { 'n' },
      -- 只有编辑 SQL 时才会用到的功能
      { '<leader>de', '<cmd>DBUIEditBindParameters<CR>', desc = '[D]atabase [E]dit Bind Parameters', buffer = ev.buf },
      { '<leader>dr', '<cmd>DBUIExecuteQuery<CR>', desc = '[D]atabase [R]un Query', buffer = ev.buf },
      { '<leader>ds', '<cmd>DBUISaveQuery<CR>', desc = '[D]atabase [S]ave Query', buffer = ev.buf },
    }
  end,
})
