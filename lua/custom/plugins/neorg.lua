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

local notes_dir = vim.fn.expand '~/notes'

vim.keymap.set('n', '<leader>nw', '<Cmd>Neorg workspace notes<CR><Cmd>e ~/notes/index.norg<CR>', { desc = 'Open Neorg notes' })
vim.keymap.set('n', '<leader>ns', function()
  require('telescope.builtin').live_grep { cwd = notes_dir, default_text = '^\\*+ ', type_filter = 'norg' }
end, { desc = 'Neorg search headings' })
vim.keymap.set('n', '<leader>nl', function()
  require('telescope.builtin').live_grep { cwd = notes_dir, default_text = '{:', type_filter = 'norg' }
end, { desc = 'Neorg find linkable' })
