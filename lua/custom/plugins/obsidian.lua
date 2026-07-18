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
  ui = { enable = false },
}

-- password concealing in obsidian vault
-- local pw_ns = vim.api.nvim_create_namespace('obsidian_pw')
-- local vault_path = vim.fn.resolve(vim.fn.expand('~/notes/obsidian'))
--
-- local function conceal_pw(buf)
--   vim.api.nvim_buf_clear_namespace(buf, pw_ns, 0, -1)
--   for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
--     local _, e = line:find('[Pp]assword:%s+')
--     if e then
--       vim.api.nvim_buf_set_extmark(buf, pw_ns, i - 1, e, { end_col = #line, conceal = '*' })
--     end
--   end
-- end
--
-- vim.api.nvim_create_autocmd('BufEnter', {
--   pattern = vim.fn.expand('~/notes/obsidian') .. '/**',
--   callback = function(ev)
--     vim.opt_local.conceallevel = 1
--     vim.opt_local.concealcursor = 'nvc'
--     conceal_pw(ev.buf)
--     vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
--       buffer = ev.buf,
--       callback = function() conceal_pw(ev.buf) end,
--     })
--   end,
-- })

local map = vim.keymap.set
map('n', '<leader>yp', function()
  local line = vim.api.nvim_get_current_line()
  local pw = line:match('[Pp]assword:%s+(.*)')
  if pw then vim.fn.setreg('+', pw) end
end, { desc = 'Yank [P]assword' })
map('n', '<leader>nn', '<cmd>ObsidianNew<cr>', { desc = '[N]ew note' })
map('n', '<leader>nf', '<cmd>ObsidianQuickSwitch<cr>', { desc = '[F]ind note' })
map('n', '<leader>ng', '<cmd>ObsidianSearch<cr>', { desc = '[Grep] in notes' })
map('n', '<leader>nb', '<cmd>ObsidianBacklinks<cr>', { desc = '[B]acklinks' })
map('n', '<leader>nd', '<cmd>ObsidianToday<cr>', { desc = '[D]aily note' })
map('n', '<leader>nl', '<cmd>ObsidianFollowLink<cr>', { desc = '[F]ollow link' })
map('n', '<leader>nt', '<cmd>ObsidianTags<cr>', { desc = '[T]ags' })
map('n', '<leader>nr', '<cmd>ObsidianRename<cr>', { desc = '[R]ename note' })
