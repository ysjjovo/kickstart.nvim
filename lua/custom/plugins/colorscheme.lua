local theme = 'tokyonight' -- 'catppuccin' | 'tokyonight' | 'onedark'

local themes = {
  catppuccin = function()
    vim.pack.add { 'https://github.com/catppuccin/nvim' }
    require('catppuccin').setup {
      styles = {
        comments = {},
      },
    }
    vim.cmd.colorscheme 'catppuccin-mocha'
  end,
  tokyonight = function()
    vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
    require('tokyonight').setup {
      styles = {
        comments = { italic = false },
      },
    }
    vim.cmd.colorscheme 'tokyonight-night'
  end,
  onedark = function()
    vim.pack.add { 'https://github.com/olimorris/onedarkpro.nvim' }
    vim.cmd.colorscheme 'onedark'
  end,
}

themes[theme]()
