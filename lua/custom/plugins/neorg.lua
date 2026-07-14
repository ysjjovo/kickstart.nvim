-- neorg: note-taking in norg format
vim.pack.add {
  { src = 'https://github.com/nvim-neorg/neorg' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/pysan3/pathlib.nvim',
  'https://github.com/nvim-neorg/lua-utils.nvim',
}

require('neorg').setup {
  load = {
    ["core.integration.telescope"] = {},
    ['core.defaults'] = {},
    ['core.concealer'] = {},
    ['core.dirman'] = {
      config = {
        workspaces = {
          notes = '~/notes',
          notion_import = "~/notion_export",
        },
        default_workspace = 'notes',
      },
    },
  },
}

vim.keymap.set('n', '<leader>nw', '<Cmd>Neorg workspace notes<CR><Cmd>e ~/notes/index.norg<CR>', { desc = 'Open Neorg notes' })
vim.keymap.set('n', '<leader>ns', '<Cmd>Telescope neorg search_headings<CR>', { desc = 'Neorg search headings' })
vim.keymap.set('n', '<leader>nl', '<Cmd>Telescope neorg find_linkable<CR>', { desc = 'Neorg find linkable' })
