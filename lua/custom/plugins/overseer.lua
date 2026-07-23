-- overseer.nvim: 任务运行器，支持 Makefile 自动检测和自定义任务模板
-- https://github.com/stevearc/overseer.nvim

vim.pack.add {
  'https://github.com/stevearc/overseer.nvim',
}

require('overseer').setup {
  strategy = 'toggleterm',
  templates = { 'builtin' },
  task_list = {
    direction = 'bottom',
    default_detail = 1,
    keymaps = {
      -- 禁用默认的滚动输出绑定，让全局 C-j/k 窗口切换生效
      ['<C-j>'] = false,
      ['<C-k>'] = false,
    },
  },
}

-- 禁止输出窗口自动换行，方便复制长行内容
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'OverseerList', 'OverseerOutput' },
  callback = function()
    vim.wo.wrap = false
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.wo.wrap = false
  end,
})

vim.keymap.set('n', '<leader>or', function()
  require('overseer').run_template({}, function(task)
    if task then
      require('overseer').open { enter = false, direction = 'bottom' }
    end
  end)
end, { desc = 'Overseer: Run task' })
vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<cr>', { desc = 'Overseer: Toggle task list' })
vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<cr>', { desc = 'Overseer: Task action' })
vim.keymap.set('n', '<leader>ol', '<cmd>OverseerRestartLast<cr>', { desc = 'Overseer: Restart last task' })
