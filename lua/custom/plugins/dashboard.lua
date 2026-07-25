vim.pack.add {
  'https://github.com/nvimdev/dashboard-nvim',
}

-- dashboard project action 会把路径直接拼在 action 字符串后面
vim.api.nvim_create_user_command('SnacksFiles', function(opts)
  Snacks.picker.files { cwd = opts.args }
end, { nargs = 1 })

require('dashboard').setup {
  theme = 'hyper',
  config = {
    shortcut = {
      { desc = 'Files', group = 'Label', action = 'lua Snacks.picker.files()', key = 'f' },
      { desc = 'Grep', group = 'Number', action = 'lua Snacks.picker.grep()', key = 'g' },
      { desc = 'Recent', group = '@property', action = 'lua Snacks.picker.recent()', key = 'r' },
      { desc = 'dotfiles', group = 'DiagnosticHint', action = 'lua Snacks.picker.files{cwd="~/.config/nvim"}', key = 'd' },
    },
    project = { enable = true, limit = 5, action = 'SnacksFiles ' },
    mru = { limit = 5 },
  },
}
