vim.pack.add { 'https://github.com/rest-nvim/rest.nvim' }

require('rest-nvim').setup {
  clients = {
    curl = {
      statistics = {
        { id = 'time_total', winbar = 'take', title = 'Time taken' },
        { id = 'size_download', winbar = 'size', title = 'Download size' },
        { id = 'time_namelookup', winbar = 'dns', title = 'DNS lookup' },
        { id = 'time_connect', winbar = 'conn', title = 'Connection time' },
      },
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'json',
  callback = function()
    vim.opt_local.formatprg = 'jq'
  end,
})

vim.keymap.set('n', '<leader>rr', '<Cmd>Rest run<CR>', { desc = '[R]est [R]un request' })
vim.keymap.set('n', '<leader>rl', '<Cmd>Rest last<CR>', { desc = '[R]est [L]ast request' })
vim.keymap.set('n', '<leader>ro', '<Cmd>Rest open<CR>', { desc = '[R]est [O]pen result pane' })
vim.keymap.set('n', '<leader>re', '<Cmd>Rest env select<CR>', { desc = '[R]est [E]nv select' })
vim.keymap.set('n', '<leader>rs', '<Cmd>Rest env show<CR>', { desc = '[R]est env [S]how' })
vim.keymap.set('n', '<leader>rc', '<Cmd>Rest cookies<CR>', { desc = '[R]est [C]ookies' })
