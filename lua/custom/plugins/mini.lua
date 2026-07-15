local gh = require('custom.plugins._util').gh

vim.pack.add { gh 'nvim-mini/mini.nvim' }

if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bd', function() MiniBufremove.delete() end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bw', function() MiniBufremove.wipeout() end, { desc = '[B]uffer [W]ipeout' })

require('mini.notify').setup {
  lsp_progress = { enable = false },
}
vim.keymap.set('n', '<leader>un', function() MiniNotify.show_history() end, { desc = 'Toggle [N]otify history'})
