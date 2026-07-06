-- yazi.nvim: terminal file manager integration for Neovim
-- https://github.com/mikavilpas/yazi.nvim

vim.pack.add {
  { src = 'https://github.com/mikavilpas/yazi.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
}

-- 禁用 netrw，让 yazi 接管目录打开
vim.g.loaded_netrwPlugin = 1

require('yazi').setup {
  -- 在浮动窗口中打开 yazi
  floating_window_scaling_factor = 0.9,
  yazi_floating_window_border = 'rounded',
  yazi_floating_window_winblend = 0,

  -- 用 yazi 替代 netrw，打开目录时自动用 yazi 显示
  open_for_directories = true,

  -- yazi 内部的快捷键
  keymaps = {
    show_help = '<f1>',
    open_file_in_vertical_split = '<c-v>',
    open_file_in_horizontal_split = '<c-x>',
    open_file_in_tab = '<c-t>',
    grep_in_directory = '<c-s>',
    cycle_open_buffers = '<tab>',
    copy_relative_path_to_selected_files = '<c-y>',
    send_to_quickfix_list = '<c-q>',
  },
}

vim.keymap.set('n', '\\', '<Cmd>Yazi<CR>', { desc = '[Y]azi at current file' })

-- 焦点离开 yazi 浮窗时自动退出（切窗口 / 鼠标点别处都会触发）。
-- 同 lazygit：yazi buffer 也是 bufhidden=hide + jobstart(term=true)，直接关窗口会留孤儿
-- 进程且跳过清理。发 'q' 让 yazi 优雅退出，走插件自己的 on_yazi_exited（utils.lua:567）
-- 完整收尾（关窗口、还原 prev_win、处理选中文件/last_cwd、跑 hooks）。
-- yazi 没有 lazygit 那种 nvim-remote 中途编辑的场景：选文件 / grep 都会让 yazi 先退出再动作，
-- 所以「焦点离开=已用完」几乎总成立，误伤概率极低。
vim.api.nvim_create_autocmd('WinLeave', {
  group = vim.api.nvim_create_augroup('YaziAutoClose', { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'yazi' then
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
