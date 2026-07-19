local gh = require('custom.plugins._util').gh

vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = 'Search (s)', mode = { 'n', 'v' } },
    { '<leader>t', group = 'Test (t)' },
    { '<leader>u', group = 'Toggle (u)' },
    { '<leader>h', group = 'Git Hunk (h)', mode = { 'n', 'v' } },
    { '<leader>d', group = 'Debug (d)' },
    { 'gr', group = 'LSP (r)', mode = { 'n' } },
    { '<leader>n', group = 'Notes (n)' },
    { '<leader>r', group = 'REST (r)' },
    { '<leader>y', group = 'Yank (y)' },
    { '<leader>a', group = 'AI Claude (a)', mode = { 'n', 'v' } },
    { '<leader>l', group = 'LazyGit (l)' },
  },
}
