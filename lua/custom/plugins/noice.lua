-- noice.nvim: 用现代浮窗 UI 替换 cmdline、messages 和 popupmenu
-- 依赖 nui.nvim 做 UI 渲染

vim.pack.add { 'https://github.com/MunifTanjim/nui.nvim' }
vim.pack.add { 'https://github.com/folke/noice.nvim' }

require('noice').setup {
  -- vim.notify 由 snacks.notifier 处理
  notify = { enabled = false },
  lsp = {
    -- hover/signature 由 Neovim 内置 LSP 处理，避免冲突
    hover = { enabled = false },
    signature = { enabled = false },
  },
  presets = {
    -- 使用底部搜索栏（/ 和 ?），不弹到中间
    bottom_search = true,
    -- cmdline 弹窗居中偏上
    command_palette = true,
    -- 长消息发送到 split 窗口而非遮挡编辑区
    long_message_to_split = true,
  },
}

-- vim.keymap.set('n', '<leader>un', '<cmd>Noice history<cr>', { desc = 'Notification history' })
-- vim.keymap.set('n', '<leader>ud', '<cmd>Noice dismiss<cr>', { desc = 'Dismiss notifications' })
