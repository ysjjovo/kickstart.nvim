-- lualine.nvim: statusline
-- https://github.com/nvim-lualine/lualine.nvim

vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
}

-- 禁用顶部 tabline，避免多 tab 时把 dropbar 挤下去
vim.o.showtabline = 0
-- 全局 statusline，多 split 时 tab 信息始终在最底部
vim.o.laststatus = 3

require('lualine').setup {
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
        -- symbols = { modified = '' },
        -- 未保存时整个文件名变橙色，提醒保存
        color = function()
          if vim.bo.modified then return { fg = '#ff9e64' } end
        end,
      },
    },
    -- 右下角始终显示 tab 页码，箭头样式
    lualine_z = {
      {
        'tabs',
        mode = 0,
        show_modified_status = true,
      },
    },
  },
}
