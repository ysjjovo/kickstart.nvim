-- claudecode.nvim: Claude Code IDE integration for Neovim
-- Implements the official VS Code extension protocol via a local WebSocket server.
-- Claude CLI connects automatically and gains awareness of your cursor/selection.

vim.pack.add {
  'https://github.com/coder/claudecode.nvim',
}

require('claudecode').setup {
  auto_start = true,
  terminal_cmd = 'claude --dangerously-skip-permissions',
  terminal = {
    split_side = 'right',
    split_width_percentage = 0.35,
    provider = 'native',
    auto_close = true,
  },
  diff_opts = {
    layout = 'vertical',
    auto_resize_terminal = true,
  },
}

-- Keymaps: <leader>a prefix for AI / Claude operations
vim.keymap.set('n', '<leader>ac', '<Cmd>ClaudeCode<CR>', { desc = '[A]I [C]laude toggle' })
vim.keymap.set('n', '<leader>af', '<Cmd>ClaudeCodeFocus<CR>', { desc = '[A]I Focus Claude' })
vim.keymap.set('n', '<leader>ar', '<Cmd>ClaudeCode --resume<CR>', { desc = '[A]I [R]esume session' })
vim.keymap.set('n', '<leader>ac', '<Cmd>ClaudeCode --continue<CR>', { desc = '[A]I [C]ontinue session' })
vim.keymap.set('n', '<leader>am', '<Cmd>ClaudeCodeSelectModel<CR>', { desc = '[A]I select [M]odel' })
vim.keymap.set('n', '<leader>ab', '<Cmd>ClaudeCodeAdd %<CR>', { desc = '[A]I add current [B]uffer' })
vim.keymap.set('v', '<leader>as', function()
  -- Exit visual mode first so that '< and '> marks get updated
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  -- Now the marks are set; send the selection
  vim.cmd "'<,'>ClaudeCodeSend"
  vim.schedule(function()
    vim.cmd 'ClaudeCodeFocus'
  end)
end, { desc = '[A]I [S]end selection' })
vim.keymap.set('n', '<leader>ay', '<Cmd>ClaudeCodeDiffAccept<CR>', { desc = '[A]I accept diff ([y]es)' })
vim.keymap.set('n', '<leader>an', '<Cmd>ClaudeCodeDiffDeny<CR>', { desc = '[A]I deny diff ([n]o)' })

-- Keyboard scrolling inside the Claude TUI.
-- Claude runs as an alt-screen TUI, so Neovim's normal-mode scrollback is empty:
-- only the mouse wheel (passed through to Claude) scrolls history. To stay on the
-- keyboard we synthesize the SGR mouse-wheel escape sequences Claude already reacts
-- to and send them straight to the terminal job.
--
-- Bindings live ONLY in terminal-normal mode (reached with <Esc><Esc>), where there
-- is no line editing — so we can reuse the idiomatic Vim scroll keys <C-u>/<C-d>
-- (half-page) and <C-y>/<C-e> (line) without touching readline's <C-u> in insert
-- mode. No PageUp/PageDown or Shift-arrows, which are awkward on a Mac laptop.
local function claude_scroll(job, up, count)
  if not job then
    return
  end
  -- SGR mouse wheel: ESC [ < Cb ; Cx ; Cy M   (64 = wheel up, 65 = wheel down)
  local seq = ('\27[<%d;1;1M'):format(up and 64 or 65)
  vim.fn.chansend(job, seq:rep(count or 1))
end

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(ev)
    if not vim.api.nvim_buf_get_name(ev.buf):lower():match 'claude' then
      return
    end
    local job = vim.b[ev.buf].terminal_job_id
    local function map(lhs, up, count, desc)
      vim.keymap.set('n', lhs, function() claude_scroll(job, up, count) end, { buffer = ev.buf, silent = true, desc = desc })
    end
    -- After <Esc><Esc>: half-page and line scrolling, Vim-style.
    map('<C-u>', true, 10, 'Claude scroll up (half page)')
    map('<C-d>', false, 10, 'Claude scroll down (half page)')
  end,
})
