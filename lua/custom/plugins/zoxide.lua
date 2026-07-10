-- telescope-zoxide: jump to frecent directories tracked by zoxide via Telescope
-- Requires the `zoxide` binary (https://github.com/ajeetdsouza/zoxide) on PATH.
if vim.fn.executable 'zoxide' == 0 then return end

vim.pack.add { 'https://github.com/jvgrootveld/telescope-zoxide' }

local telescope = require 'telescope'

telescope.load_extension 'zoxide'

vim.keymap.set('n', '<leader>sz', telescope.extensions.zoxide.list, { desc = '[S]earch [Z]oxide directories' })
