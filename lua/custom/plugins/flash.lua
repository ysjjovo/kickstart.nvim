-- flash.nvim: jump to any visible location by typing 1-2 chars
vim.pack.add { 'https://github.com/folke/flash.nvim' }

require('flash').setup {
  modes = {
    char = {
      enabled = false
    },
  },
}

vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash Jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })

vim.keymap.set('c', '<c-s>', function() require('flash').toggle() end, { desc = 'Toggle Flash Search' })
