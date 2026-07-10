-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', 'f', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      visible = true, -- 被过滤的项会以灰色显示而非完全隐藏
      hide_dotfiles = false, -- 显示以 . 开头的隐藏文件
      hide_gitignored = false, -- 显示被 .gitignore 忽略的文件
    },
    window = {
      mappings = {
        ['q'] = 'close_window',
        ['ca'] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg('+', path, 'c')
            vim.notify('Copied path: ' .. path)
          end,
          desc = 'Copy Absolute Path',
        },
        ['cr'] = {
          function(state)
            local node = state.tree:get_node()
            local full_path = node:get_id()
            local relative_path = vim.fn.fnamemodify(full_path, ':~:.')
            vim.fn.setreg('+', relative_path, 'c')
            vim.notify('Copied relative path: ' .. relative_path)
          end,
          desc = 'Copy Relative Path',
        },
      },
    },
  },
}
