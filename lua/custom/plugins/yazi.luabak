-- yazi.nvim: terminal file manager integration for Neovim
-- https://github.com/mikavilpas/yazi.nvim

vim.pack.add {
  { src = 'https://github.com/mikavilpas/yazi.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
}

-- 禁用 netrw，让 yazi 接管目录打开
vim.g.loaded_netrwPlugin = 1

-- 这些扩展名交给系统默认程序打开（对应 cli ~/.config/yazi/yazi.toml 里走 `open` 的类型）。
-- yazi.nvim 用 chooser 模式（--chooser-file）启动 yazi，按 Enter 只把路径回传给 nvim，
-- 并不会执行 yazi.toml 的 [open] 规则，默认一律 :edit。这里在 nvim 侧复刻那套分流。
local system_open_ext = {
  -- office 文档
  xlsx = true, xls = true, docx = true, doc = true, pptx = true, ppt = true,
  -- pdf / 图形
  pdf = true, drawio = true,
  -- 图片
  png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true, tiff = true, heic = true,
  -- 音视频
  mp4 = true, mov = true, mkv = true, avi = true, webm = true, mp3 = true, wav = true, flac = true, m4a = true,
}

require('yazi').setup {
  -- 在浮动窗口中打开 yazi
  floating_window_scaling_factor = 0.9,
  yazi_floating_window_border = 'rounded',
  yazi_floating_window_winblend = 0,

  -- 用 yazi 替代 netrw，打开目录时自动用 yazi 显示
  open_for_directories = true,

  -- 打开文件时按扩展名分流：文件夹/文档/图片/音视频走系统 open，其余在 nvim 里 :edit
  open_file_function = function(chosen_file)
    -- 文件夹交给 macOS 访达打开
    if vim.fn.isdirectory(chosen_file) == 1 then
      vim.ui.open(chosen_file) -- macOS 上用访达打开目录
      return
    end
    local ext = chosen_file:match '%.([^.]+)$'
    if ext and system_open_ext[ext:lower()] then
      vim.ui.open(chosen_file) -- macOS 上等价于 `open`
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(chosen_file))
  end,

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

vim.keymap.set('n', 'f', '<Cmd>Yazi<CR>', { desc = '[Y]azi at current file' })
vim.keymap.set('n', 'F', '<Cmd>Yazi cwd<CR>', { desc = '[Y]azi at current working directory' })

-- | (Shift+\)：在当前项目根目录打开 yazi（找 .git 等标记，找不到就退回 cwd）
-- vim.keymap.set('n', '|', function()
--  local root = vim.fs.root(0, { '.git', '.hg', '.svn', 'package.json', 'Cargo.toml', 'go.mod', 'Makefile' })
--  require('yazi').yazi({}, root or vim.fn.getcwd())
--end, { desc = '[Y]azi at project root' })

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
