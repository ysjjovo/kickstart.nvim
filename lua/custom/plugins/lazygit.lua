-- lazygit.nvim: seamless lazygit integration for neovim
-- https://github.com/kdheepak/lazygit.nvim

vim.pack.add {
  'https://github.com/kdheepak/lazygit.nvim',
}

-- 快捷键
vim.keymap.set('n', '<leader>ug', '<Cmd>LazyGit<CR>', { desc = 'Toogle [L]azygit' })
--vim.keymap.set('n', '<leader>lf', '<Cmd>LazyGitFilter<CR>', { desc = 'LazyGit [F]ilter (project commits)' })
--vim.keymap.set('n', '<leader>lc', '<Cmd>LazyGitFilterCurrentFile<CR>', { desc = 'LazyGit [C]urrent file commits' })

-- 焦点离开 lazygit 浮窗时自动退出（切窗口 / 鼠标点别处都会触发）。
-- 为什么发 'q' 而不是直接关窗口：
--   * lazygit buffer 是 bufhidden=hide，nvim_win_close 只藏窗口，后台进程仍在跑，
--     下次 :LazyGit 走「新建 buffer」分支（window.lua:47），旧进程变孤儿、全局状态 desync。
--   * on_exit 里 `if code ~= 0 then return`（lazygit.lua:19），所以 jobstop 强杀会跳过清理，
--     LAZYGIT_LOADED 不复位 → 状态错乱。发 'q' 让 lazygit 正常退出（code 0），
--     插件自己的 on_exit 会完整清理（关窗口、删 buffer、checktime 重载改动）。
-- 可接受的降级：若正停在 lazygit 子面板里，'q' 只返回上一层而非退出，此时不自动关，
-- 窗口保留但状态无损；nvim-remote 编辑 commit 时焦点合法离开也会误发 'q'（概率低）。
vim.api.nvim_create_autocmd('WinLeave', {
  group = vim.api.nvim_create_augroup('LazygitAutoClose', { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'lazygit' then
      return
    end
    if vim.api.nvim_win_get_config(0).relative == '' then -- 仅浮窗
      return
    end
    local job = vim.b[buf].terminal_job_id
    if job then
      pcall(vim.fn.chansend, job, 'q')
    end
  end,
})
