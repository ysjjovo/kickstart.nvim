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
  },
}

vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<cr>', { desc = 'Overseer: Run task' })
vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<cr>', { desc = 'Overseer: Toggle task list' })
vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<cr>', { desc = 'Overseer: Task action' })
vim.keymap.set('n', '<leader>ol', '<cmd>OverseerRestartLast<cr>', { desc = 'Overseer: Restart last task' })
