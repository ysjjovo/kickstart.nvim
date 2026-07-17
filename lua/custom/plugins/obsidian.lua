vim.pack.add {
  { src = 'https://github.com/epwalsh/obsidian.nvim' },
  'https://github.com/nvim-lua/plenary.nvim',
}

require('obsidian').setup {
  workspaces = {
    { name = 'notes', path = '~/notes/obsidian' },
  },
  preferred_link_style = 'wiki',
  new_notes_location = 'current_dir',
  note_id_func = function(title)
    return title
  end,
}

local map = vim.keymap.set
map('n', '<leader>nn', '<cmd>ObsidianNew<cr>', { desc = 'New note' })
map('n', '<leader>nf', '<cmd>ObsidianQuickSwitch<cr>', { desc = 'Find note' })
map('n', '<leader>ns', '<cmd>ObsidianSearch<cr>', { desc = 'Search in notes' })
map('n', '<leader>nb', '<cmd>ObsidianBacklinks<cr>', { desc = 'Backlinks' })
map('n', '<leader>nd', '<cmd>ObsidianToday<cr>', { desc = 'Daily note' })
map('n', '<leader>nl', '<cmd>ObsidianFollowLink<cr>', { desc = 'Follow link' })
map('n', '<leader>nt', '<cmd>ObsidianTags<cr>', { desc = 'Tags' })
map('n', '<leader>nr', '<cmd>ObsidianRename<cr>', { desc = 'Rename note' })
