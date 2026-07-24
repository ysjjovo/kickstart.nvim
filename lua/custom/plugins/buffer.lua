-- bufferline.nvim: buffer tabs at the top
vim.pack.add { 'https://github.com/akinsho/bufferline.nvim' }

require('bufferline').setup {
  options = {
    diagnostics = 'nvim_lsp',
    -- offsets = {
    --   { filetype = 'neo-tree', text = 'File Explorer', highlight = 'Directory' },
    --   { filetype = 'oil', text = 'Oil', highlight = 'Directory' },
    -- },
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = 'thin',
  },
}

vim.keymap.set('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', { desc = '[B]uffer [P]in' })
vim.keymap.set('n', 'H', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', 'L', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', { desc = '[B]uffer close [O]thers' })
vim.keymap.set({ 'n', 'v' }, '<leader>bf', function() require('conform').format { async = true } end, { desc = '[B]uffer [F]ormat' })
vim.keymap.set('n', '<leader>bs', function() Snacks.scratch() end, { desc = 'Toggle Scratch buffer' })
vim.keymap.set('n', 'q', function() MiniBufremove.delete() end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bw', function() MiniBufremove.wipeout() end, { desc = '[B]uffer [W]ipeout' })

vim.keymap.set('n', '<leader>bq', vim.diagnostic.setloclist, { desc = '[B]uffer diagnostic [Q]uickfix list' })
  -- quickfix/loclist 窗口按 q 关闭
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function(ev)
      vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = ev.buf })
    end,
  })
