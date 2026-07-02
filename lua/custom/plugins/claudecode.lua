-- claudecode.nvim: Claude Code IDE integration for Neovim
-- Implements the official VS Code extension protocol via a local WebSocket server.
-- Claude CLI connects automatically and gains awareness of your cursor/selection.

vim.pack.add {
  'https://github.com/coder/claudecode.nvim',
}

require('claudecode').setup {
  auto_start = true,
  terminal_cmd = 'claude --dangerously-skip-permissions',
  terminal = {
    split_side = 'right',
    split_width_percentage = 0.35,
    provider = 'native',
    auto_close = true,
  },
  diff_opts = {
    layout = 'vertical',
    auto_resize_terminal = true,
  },
}

-- Keymaps: <leader>a prefix for AI / Claude operations
vim.keymap.set('n', '<leader>ac', '<Cmd>ClaudeCode<CR>', { desc = '[A]I [C]laude toggle' })
vim.keymap.set('n', '<leader>af', '<Cmd>ClaudeCodeFocus<CR>', { desc = '[A]I [F]ocus Claude' })
vim.keymap.set('n', '<leader>ar', '<Cmd>ClaudeCode --resume<CR>', { desc = '[A]I [R]esume session' })
vim.keymap.set('n', '<leader>aC', '<Cmd>ClaudeCode --continue<CR>', { desc = '[A]I [C]ontinue session' })
vim.keymap.set('n', '<leader>am', '<Cmd>ClaudeCodeSelectModel<CR>', { desc = '[A]I select [M]odel' })
vim.keymap.set('n', '<leader>ab', '<Cmd>ClaudeCodeAdd %<CR>', { desc = '[A]I add current [B]uffer' })
vim.keymap.set('v', '<leader>as', function()
  vim.cmd "'<,'>ClaudeCodeSend"
  vim.schedule(function()
    vim.cmd 'ClaudeCodeFocus'
  end)
end, { desc = '[A]I [S]end selection' })
vim.keymap.set('n', '<leader>aa', '<Cmd>ClaudeCodeDiffAccept<CR>', { desc = '[A]I [A]ccept diff' })
vim.keymap.set('n', '<leader>ad', '<Cmd>ClaudeCodeDiffDeny<CR>', { desc = '[A]I [D]eny diff' })
