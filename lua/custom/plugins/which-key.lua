local gh = require('custom.plugins._util').gh

vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>b', group = 'Buffer', mode = { 'n', 'v' } },
    { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
    { '<leader>t', group = 'Test' },
    { '<leader>u', group = 'UI' },
    { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    { '<leader>d', group = 'Debug' },
    { 'gr', group = 'LSP', mode = { 'n' } },
    { '<leader>n', group = 'Notes', mode = { 'n', 'v' } },
    { '<leader>o', group = 'Overseer', mode = { 'n', 'v' } },
    { '<leader>r', group = 'Rest' },
    { '<leader>w', group = 'Window' },
    { '<leader>y', group = 'Yank' },
    { '<leader>a', group = 'AI', mode = { 'n', 'v' } },
  },
}
