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

-- Keymaps: <leader>y prefix for yazi operations
vim.keymap.set('n', '<leader>y', '<Cmd>Yazi<CR>', { desc = '[Y]azi at current file' })
vim.keymap.set('n', '<leader>Y', '<Cmd>Yazi cwd<CR>', { desc = '[Y]azi at working directory' })
vim.keymap.set('n', '<c-up>', '<Cmd>Yazi toggle<CR>', { desc = 'Resume last yazi session' })
