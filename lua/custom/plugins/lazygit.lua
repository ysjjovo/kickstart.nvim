-- lazygit.nvim: seamless lazygit integration for neovim
-- https://github.com/kdheepak/lazygit.nvim

vim.pack.add {
  'https://github.com/kdheepak/lazygit.nvim',
}

-- 基本配置
vim.g.lazygit_floating_window_winblend = 0 -- 窗口透明度
vim.g.lazygit_floating_window_scaling_factor = 0.9 -- 窗口大小比例
vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
vim.g.lazygit_floating_window_use_plenary = 0 -- 不依赖 plenary
vim.g.lazygit_use_neovim_remote = 1 -- 从 lazygit 内编辑文件时复用当前 neovim 实例
vim.g.lazygit_use_custom_config_file_path = 0

-- 快捷键
vim.keymap.set('n', '<leader>lg', '<Cmd>LazyGit<CR>', { desc = '[T]erminal Lazygit Toogle' })
vim.keymap.set('n', '<leader>lf', '<Cmd>LazyGitFilter<CR>', { desc = 'LazyGit [F]ilter (project commits)' })
vim.keymap.set('n', '<leader>lc', '<Cmd>LazyGitFilterCurrentFile<CR>', { desc = 'LazyGit [C]urrent file commits' })
