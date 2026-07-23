-- lazygit.nvim: seamless lazygit integration for neovim
-- https://github.com/kdheepak/lazygit.nvim

vim.pack.add {
  'https://github.com/kdheepak/lazygit.nvim',
}

-- 快捷键
vim.keymap.set('n', '<leader>ug', '<Cmd>LazyGit<CR>', { desc = 'Toogle [L]azygit' })

local lazygit_win = nil
local lazygit_buf = nil
local lazygit_augroup = vim.api.nvim_create_augroup('LazygitIntegration', { clear = true })

-- 记录 lazygit 浮窗和 buffer
vim.api.nvim_create_autocmd('TermOpen', {
  group = lazygit_augroup,
  callback = function(ev)
    vim.schedule(function()
      if vim.bo[ev.buf].filetype == 'lazygit' then
        lazygit_buf = ev.buf
        lazygit_win = vim.api.nvim_get_current_win()
      end
    end)
  end,
})

-- lazygit 退出时清理状态
vim.api.nvim_create_autocmd('TermClose', {
  group = lazygit_augroup,
  callback = function(ev)
    if ev.buf == lazygit_buf then
      lazygit_win = nil
      lazygit_buf = nil
    end
  end,
})

-- nvim-remote 编辑支持：lazygit 按 e 时隐藏浮窗，聚焦到文件，编辑完恢复
vim.api.nvim_create_autocmd('BufEnter', {
  group = lazygit_augroup,
  callback = function(ev)
    if not lazygit_win or not vim.api.nvim_win_is_valid(lazygit_win) then return end
    if ev.buf == lazygit_buf then return end
    if vim.bo[ev.buf].buftype ~= '' then return end
    -- 普通文件进入，说明 nvim-remote 打开了文件，隐藏 lazygit 浮窗并聚焦文件
    vim.api.nvim_win_hide(lazygit_win)
    vim.api.nvim_set_current_buf(ev.buf)
    -- 关闭该 buffer 时恢复 lazygit
    vim.api.nvim_create_autocmd('BufDelete', {
      buffer = ev.buf,
      once = true,
      callback = function()
        if not lazygit_buf or not vim.api.nvim_buf_is_valid(lazygit_buf) then return end
        local new_win = require('lazygit.window').open_floating_window()
        vim.api.nvim_win_set_buf(new_win, lazygit_buf)
        lazygit_win = new_win
        vim.cmd('startinsert')
      end,
    })
  end,
})

-- 焦点离开 lazygit 浮窗时自动退出（切窗口 / 鼠标点别处都会触发）
-- 发 'q' 让 lazygit 正常退出，插件的 on_exit 会完整清理
vim.api.nvim_create_autocmd('WinLeave', {
  group = lazygit_augroup,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'lazygit' then return end
    if vim.api.nvim_win_get_config(0).relative == '' then return end
    local job = vim.b[buf].terminal_job_id
    if not job then return end
    vim.schedule(function()
      local new_buf = vim.api.nvim_get_current_buf()
      -- nvim-remote 打开了普通文件，不退出 lazygit
      if vim.bo[new_buf].buftype == '' then return end
      pcall(vim.fn.chansend, job, 'q')
    end)
  end,
})
