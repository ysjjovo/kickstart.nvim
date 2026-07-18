-- spamguard: nudge toward efficient motions when spamming movement keys
vim.pack.add { 'https://github.com/timseriakov/spamguard.nvim' }

local spamguard = require('spamguard')

spamguard.setup {
  keys = {
    j = { threshold = 9, suggestion = 'use f instead of spamming jjjj' },
    k = { threshold = 9, suggestion = 'try { or ( instead of spamming kkkk' },
    h = { threshold = 9, suggestion = 'use b / 0 / ^ instead of spamming hhhh' },
    l = { threshold = 9, suggestion = 'try w / e / f — it\'s faster!' },
    w = { threshold = 8, suggestion = 'use f — more precise and quicker!' },
  },
}

vim.schedule(function()
  spamguard.enable()
end)
