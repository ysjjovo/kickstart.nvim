-- noice.nvim: 用现代浮窗 UI 替换 cmdline、messages 和 popupmenu
-- 依赖 nui.nvim 做 UI 渲染

vim.pack.add { 'https://github.com/MunifTanjim/nui.nvim' }
vim.pack.add { 'https://github.com/folke/noice.nvim' }

require('noice').setup {
  lsp = {
    -- 接管 LSP hover/signature 的渲染，用 treesitter 高亮替代 vim 内置 markdown
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    -- 使用底部搜索栏（/ 和 ?），不弹到中间
    bottom_search = true,
    -- cmdline 弹窗居中偏上
    command_palette = true,
    -- 长消息发送到 split 窗口而非遮挡编辑区
    long_message_to_split = true,
    -- LSP hover 文档不加边框（更简洁）
    lsp_doc_border = false,
  },
}

vim.keymap.set('n', '<leader>un', '<cmd>Noice history<cr>', { desc = 'Notification history' })
-- vim.keymap.set('n', '<leader>ud', '<cmd>Noice dismiss<cr>', { desc = 'Dismiss notifications' })
