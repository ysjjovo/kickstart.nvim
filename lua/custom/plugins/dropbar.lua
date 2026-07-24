-- dropbar.nvim: 顶部面包屑导航栏（winbar）
-- https://github.com/Bekaboo/dropbar.nvim

vim.pack.add {
  'https://github.com/Bekaboo/dropbar.nvim',
}

require('dropbar').setup {
  icons = {
    ui = {
      bar = {
        separator = '  ',
      },
    },
  },
}
