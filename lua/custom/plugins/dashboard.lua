vim.pack.add {
  'https://github.com/nvimdev/dashboard-nvim',
}

require('dashboard').setup {
  theme = 'hyper',
  config = {
    shortcut = {
      { desc = 'Files', group = 'Label', action = 'Telescope find_files', key = 'f' },
      { desc = 'Grep', group = 'Number', action = 'Telescope live_grep', key = 'g' },
      { desc = 'Recent', group = '@property', action = 'Telescope oldfiles', key = 'r' },
      { desc = 'dotfiles', group = 'DiagnosticHint', action = 'Telescope find_files cwd=~/.config/nvim', key = 'd' },
    },
    project = { enable = true, limit = 5, action = 'Telescope find_files cwd=' },
    mru = { limit = 5 },
  },
}
