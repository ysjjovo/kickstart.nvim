-- lualine.nvim: statusline
-- https://github.com/nvim-lualine/lualine.nvim

vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
}

require('lualine').setup {
  sections = {
    -- 1 = relative path
    lualine_c = { { 'filename', path = 1 } },
  },
}
