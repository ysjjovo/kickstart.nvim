local M = {}

function M.open(file)
  -- 隐藏 lazygit 浮窗，切到主窗口打开文件
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(w)
    if cfg.relative ~= '' and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == 'terminal' then
      vim.api.nvim_win_hide(w)
      break
    end
  end
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(w).relative == '' then
      vim.api.nvim_set_current_win(w)
      break
    end
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(file))
  return ''
end

return M
