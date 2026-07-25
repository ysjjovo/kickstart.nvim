-- zoxide: jump to frecent directories via Snacks.picker
-- Requires the `zoxide` binary (https://github.com/ajeetdsouza/zoxide) on PATH.
if vim.fn.executable 'zoxide' == 0 then return end

vim.keymap.set('n', '<leader>sz', function() Snacks.picker.zoxide() end, { desc = '[S]earch [Z]oxide directories' })
