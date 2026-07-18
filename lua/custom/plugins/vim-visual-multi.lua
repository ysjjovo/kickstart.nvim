-- vim-visual-multi: multiple cursors support
vim.pack.add { 'https://github.com/mg979/vim-visual-multi' }

-- 使用 Ctrl 系快捷键，与主流编辑器一致
vim.g.VM_maps = {
  ['Find Under'] = '<C-n>',       -- 选中当前词，继续按选下一个
  ['Find Subword Under'] = '<C-n>',
  ['Select All'] = '<C-S-n>',     -- 选中所有匹配
  ['Add Cursor Down'] = '<C-Down>',
  ['Add Cursor Up'] = '<C-Up>',
  ['Skip Region'] = 'q',          -- 跳过当前匹配
  ['Remove Region'] = 'Q',        -- 移除当前光标
}

-- 退出多光标后不要覆盖系统寄存器
vim.g.VM_silent_exit = 1
