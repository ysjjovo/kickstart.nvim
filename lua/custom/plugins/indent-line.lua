vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {
  exclude = { filetypes = { 'dashboard' } },
}
