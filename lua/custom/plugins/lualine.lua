-- lualine.nvim: statusline
-- https://github.com/nvim-lualine/lualine.nvim

vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
}

-- 禁用顶部 tabline，避免多 tab 时把 dropbar 挤下去
vim.o.showtabline = 0

require('lualine').setup {
  sections = {
    lualine_c = { { 'filename', path = 3, symbols = { modified = ' ●' } } },
    -- 多 tab 时在右下角显示页码
    lualine_z = { { 'tabs', mode = 0, show_modified_status = false } },
  },
}
