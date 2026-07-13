-- vim-local-history: file local history on save
-- https://github.com/dinhhuy258/vim-local-history

vim.pack.add {
  'https://github.com/dinhhuy258/vim-local-history',
}

-- vim.g.local_history_path = vim.fn.expand '~/.local-history'
-- vim.g.local_history_max_changes = 100
-- vim.g.local_history_new_change_delay = 300
vim.g.local_history_exclude = { '**/node_modules/**', '**/.git/**', '**/.venv/**', '**/venv/**', '**/__pycache__/**', '**/*.pyc' }

vim.keymap.set('n', '<leader>ul', '<Cmd>LocalHistoryToggle<CR>', { desc = 'Toogle [L]ocal history' })
