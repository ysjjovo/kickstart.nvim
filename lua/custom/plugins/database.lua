-- vim-dadbod: database client for Neovim
-- Supports PostgreSQL, MySQL, SQLite, MongoDB, Redis, etc.

vim.pack.add {
  'https://github.com/tpope/vim-dadbod',
  'https://github.com/kristijanhusak/vim-dadbod-ui',
  'https://github.com/kristijanhusak/vim-dadbod-completion',
}

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
vim.g.db_ui_winwidth = 50
vim.g.db_ui_auto_execute_table_helpers = 1

-- Toggle the DBUI drawer from anywhere (归入 <leader>u = UI/Toggle 分组)
-- 关闭时连同所有查询结果窗口(dbout)一起关，避免残留空窗
local function db_ui_toggle()
  local drawer_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dbui' then
      drawer_open = true
      break
    end
  end

  if drawer_open then
    -- 先关掉所有结果窗口(dbout)，再关抽屉；SQL 编辑窗口(sql)保持不动
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dbout' then
        pcall(function()
          vim.api.nvim_win_close(win, false)
        end)
      end
    end
    vim.cmd 'DBUIClose'
  else
    vim.cmd 'DBUI'
  end
end

vim.keymap.set('n', '<leader>ud', db_ui_toggle, { desc = 'Toggle [D]atabase UI (含结果窗口)' })

-- SQL 缓冲区内的操作直接用 vim-dadbod-ui 的默认键（单键，无需自定义）：
--   <leader>S  执行查询（normal=整个文件，visual=仅选中部分）
--   <leader>W  保存查询到 g:db_ui_save_location
--   <leader>E  编辑绑定参数
--   <leader>R  切换结果布局
-- 详见 :help dadbod-ui-mappings
