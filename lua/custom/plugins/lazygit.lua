-- lazygit.nvim: seamless lazygit integration for neovim
-- https://github.com/kdheepak/lazygit.nvim

vim.pack.add {
  'https://github.com/kdheepak/lazygit.nvim',
}

vim.keymap.set('n', '<leader>ug', '<Cmd>LazyGit<CR>', { desc = 'Toogle [L]azygit' })
vim.keymap.set('n', '<leader>ulf', '<Cmd>LazyGitFilter<CR>', { desc = 'LazyGit [F]ilter (project commits)' })
vim.keymap.set('n', '<leader>ulc', '<Cmd>LazyGitFilterCurrentFile<CR>', { desc = 'LazyGit [C]urrent file commits' })

-- 焦点离开 lazygit 浮窗时自动退出
vim.api.nvim_create_autocmd('WinLeave', {
  group = vim.api.nvim_create_augroup('LazygitAutoClose', { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'lazygit' then return end
    if vim.api.nvim_win_get_config(0).relative == '' then return end
    local job = vim.b[buf].terminal_job_id
    if not job then return end
    vim.schedule(function()
      -- nvim-remote/edit 触发时焦点到普通 buffer，不退出
      if vim.bo[vim.api.nvim_get_current_buf()].buftype == '' then return end
      pcall(vim.fn.chansend, job, 'q')
    end)
  end,
})
