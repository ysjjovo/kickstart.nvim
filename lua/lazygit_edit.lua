local M = {}

function M.open(file, line, flag)
  -- 找到 lazygit 浮窗并隐藏
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.bo[buf].filetype == 'lazygit' then
      vim.api.nvim_win_hide(w)
      break
    end
  end

  -- 在主窗口打开文件
  vim.cmd('edit ' .. vim.fn.fnameescape(file))
  if line > 1 then
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
  end

  -- buffer 关闭时写 flag 文件，通知脚本编辑完成
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufUnload' }, {
    buffer = bufnr,
    once = true,
    callback = function()
      vim.fn.writefile({}, flag)
      -- 恢复 lazygit
      vim.schedule(function()
        vim.cmd('LazyGit')
      end)
    end,
  })

  return ''
end

return M
