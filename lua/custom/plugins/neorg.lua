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
    ['core.concealer'] = {
      config = {
        icon_preset = 'varied',
        icons = {
          code_block = { conceal = true, width = 'fullwidth' },
        },
      },
    },
    ['core.dirman'] = {
      config = {
        workspaces = {
          notes = '~/notes',
        },
        default_workspace = 'notes',
      },
    },
  },
}

local notes_dir = vim.fn.expand '~/notes'

vim.keymap.set('n', '<leader>nw', '<Cmd>Neorg workspace notes<CR><Cmd>e ~/notes/index.norg<CR>', { desc = 'Open Neorg notes' })
vim.keymap.set('n', '<leader>ns', function()
  require('telescope.builtin').live_grep { cwd = notes_dir, default_text = '^\\*+ ', glob_pattern = '*.norg' }
end, { desc = 'Neorg search headings' })
vim.keymap.set('n', '<leader>nl', function()
  require('telescope.builtin').live_grep { cwd = notes_dir, default_text = '\\{/ ', glob_pattern = '*.norg' }
end, { desc = 'Neorg find linkable' })
vim.keymap.set('n', '<leader>nf', function()
  require('telescope.builtin').find_files { cwd = notes_dir }
end, { desc = 'Neorg find file' })
vim.keymap.set('n', '<leader>ng', function()
  require('telescope.builtin').live_grep { cwd = notes_dir }
end, { desc = 'Neorg grep content' })

vim.api.nvim_set_hl(0, '@neorg.tags.ranged_verbatim.code_block', { bg = '#313244' })

local ns = vim.api.nvim_create_namespace("neorg_pw")

local function conceal_pw(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local _, e = line:find("[Pp]assword:%s+")
        if e then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, e, { end_col = #line, conceal = "*" })
        end
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "norg",
    callback = function(ev)
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nv"
        conceal_pw(ev.buf)
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { buffer = ev.buf, callback = function() conceal_pw(ev.buf) end })
    end,
})
vim.keymap.set("n", "<leader>yp", function()
    local line = vim.api.nvim_get_current_line()
    local pw = line:match("[Pp]assword:%s+(.*)")
    if pw then vim.fn.setreg("+", pw) end
end, { desc = 'Yank [P]assword' })
