local theme = 'catppuccin' -- 'catppuccin' | 'tokyonight' | 'onedark' | 'onedarkpro'

local themes = {
  catppuccin = function()
    vim.pack.add { 'https://github.com/catppuccin/nvim' }
    require('catppuccin').setup {
      no_italic = true,
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
  onedarkpro = function()
    vim.pack.add { 'https://github.com/olimorris/onedarkpro.nvim' }
    vim.cmd.colorscheme 'onedark'
  end,
  ['onedark'] = function()
    vim.pack.add { 'https://github.com/joshdick/onedark.vim' }
    vim.cmd.colorscheme 'onedark'
  end,
}

themes[theme]()
