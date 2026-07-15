-- claudecode.nvim: Claude Code IDE integration for Neovim
-- Implements the official VS Code extension protocol via a local WebSocket server.
-- Claude CLI connects automatically and gains awareness of your cursor/selection.

vim.pack.add {
  'https://github.com/coder/claudecode.nvim',
}

-- 依赖顺序：custom/plugins 按文件名字母序加载，claudecode 排在 snacks 前面。
-- 但 snacks provider 在首次加载时会 pcall(require, 'snacks') 并「永久缓存」结果，
-- 若此刻 snacks 还没进 runtimepath 就会回退到 native。这里先强制加载 snacks
-- （require 有缓存，loop 再次 require 时是空操作），保证 float provider 可用。
require 'custom.plugins.snacks'

-- 只改这一个变量即可切换窗口形态：'float' = 居中浮窗，'split' = 右侧固定分屏。
local claude_layout = 'split'

-- 两种形态各自的 snacks 窗口配置。float 走浮窗那套（居中 + 边框 + 关暗化层）；
-- split 走右侧固定分屏（不需要 border/backdrop，宽度占 40%）。
local claude_win_opts = {
  float = {
    position = 'float',
    width = 0.9,
    height = 0.9,
    border = 'rounded',
    backdrop = false, -- 关掉背后暗化层：既不遮挡，也避免自动隐藏时 backdrop 残留
  },
  split = {
    position = 'right',
    width = 0.4,
  },
}

require('claudecode').setup {
  auto_start = true,
  terminal_cmd = 'claude --dangerously-skip-permissions',
  ---@diagnostic disable-next-line: missing-fields
  terminal = {
    provider = 'snacks', -- float 需要 snacks provider（native 只能分屏）
    auto_close = true,
    snacks_win_opts = claude_win_opts[claude_layout],
  },
  ---@diagnostic disable-next-line: missing-fields
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

-- Float 场景专用：在「普通模式」和「终端模式」下都能用同一个键收起/唤出浮窗。
-- <Cmd> 映射在终端模式下可直接执行，无需先退出 insert。ClaudeCode = 隐藏/显示，
-- 正是浮窗要的语义（在 Claude 里按 → 收起回到 buffer；在 buffer 里按 → 唤出并聚焦）。
vim.keymap.set({ 'n', 't' }, '<M-a>', '<Cmd>ClaudeCode<CR>', { desc = 'AI toggle Claude float' })

-- 焦点离开 Claude 浮窗时自动收起，避免它盖住你切过去看的 buffer（如按 <C-j> 切窗口）。
-- 关键点：
--   * 直接对窗口设 {hide=true}，与插件内部对 float 的 cc_hide 完全一致（同一个窗口、
--     只隐藏不销毁 buffer/进程），状态不会 desync；之后 <C-q> 能正常唤回。
--   * {hide=true} 是幂等的，重复隐藏无害，所以和 <C-q> 的 toggle 永远不会互相触发成环。
--   * 仅处理 float（relative ~= ''）；split 模式两边本就并排可见，自动跳过。
vim.api.nvim_create_autocmd('WinLeave', {
  group = vim.api.nvim_create_augroup('ClaudeFloatAutoHide', { clear = true }),
  callback = function()
    local ok, term = pcall(require, 'claudecode.terminal')
    if not ok then
      return
    end
    -- 只在「正离开的窗口就是 Claude 终端」时动作
    if vim.api.nvim_get_current_buf() ~= term.get_active_terminal_bufnr() then
      return
    end
    local win = vim.api.nvim_get_current_win()
    -- 延后到窗口切换完成后再隐藏（此刻焦点还在 Claude，不能隐藏当前窗口）
    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= '' then -- 浮窗才隐藏；split 跳过
        pcall(vim.api.nvim_win_set_config, win, { hide = true })
      end
    end)
  end,
})
vim.keymap.set('v', '<leader>as', "<cmd>ClaudeCodeSend<cr>", { desc = '[A]I [S]end selection' })
-- vim.keymap.set('v', '<leader>as', function()
--   vim.cmd 'ClaudeCodeSend'
--   vim.schedule(function()
--     vim.cmd 'ClaudeCodeFocus'
--   end)
-- end, { desc = '[A]I [S]end selection' })
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
    -- 单键 ESC 直接退出终端模式，不发给 Claude TUI（它不需要 ESC），消除双击延迟
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = ev.buf, nowait = true, desc = 'Exit terminal mode' })

    local job = vim.b[ev.buf].terminal_job_id
    local function map(lhs, up, count, desc)
      vim.keymap.set('n', lhs, function() claude_scroll(job, up, count) end, { buffer = ev.buf, silent = true, desc = desc })
    end
    -- After <Esc><Esc>: half-page and line scrolling, Vim-style.
    map('<C-u>', true, 10, 'Claude scroll up (half page)')
    map('<C-d>', false, 10, 'Claude scroll down (half page)')
    -- Normal 模式按 q 收起 Claude 浮窗（等同 <M-a>，隐藏不销毁进程）
    vim.keymap.set('n', 'q', '<Cmd>ClaudeCode<CR>', { buffer = ev.buf, nowait = true, desc = 'Claude [q]uit' })
    -- 窗口切换 <C-hjkl> 已在 init.lua 里全局绑定 normal + terminal 模式，这里不用再重复绑定。
  end,
})
