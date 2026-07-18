-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()
  require('vim._core.ui2').enable()

  package.path = package.path .. ';' .. vim.fn.expand('~/.luarocks/share/lua/5.4/?.lua')
  package.cpath = package.cpath .. ';' .. vim.fn.expand('~/.luarocks/lib/lua/5.4/?.so')

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`
  vim.opt.conceallevel = 2

  -- Make line numbers default
  vim.o.number = true
  -- You can also add relative line numbers, to help with jumping.
  --  Experiment for yourself to see if you like it!
  -- vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 1000

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣'}

-- ============================================================
-- Python3 provider: use dedicated venv so it works in any project
-- ============================================================
vim.g.python3_host_prog = vim.fn.expand('~/.config/nvim/.venv/bin/python3')

-- 禁用不需要的 provider，消除 checkhealth 警告
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ============================================================
-- Indentation: tab = 2 spaces
-- ============================================================
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  -- vim.o.scrolloff = 10
  -- vim.o.sidescrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  -- Blinking cursor
  vim.opt.guicursor = {
    "n-v-c:block-blinkwait700-blinkon400-blinkoff400",
    "i-ci-ve:ver25-blinkwait700-blinkon400-blinkoff400",
    "r-cr:hor20-blinkwait700-blinkon400-blinkoff400",
    "o:hor50-blinkwait700-blinkon400-blinkoff400",
    "t:ver25-blinkwait700-blinkon400-blinkoff400",
  }
end

-- ============================================================
-- SECTION 2: KEYMAPS
-- basic keymaps
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows, in both normal and terminal mode.
  --  统一在这里绑定 normal + terminal 两种模式，各插件（toggleterm/claudecode 等）里的
  --  终端窗口就不用再各自绑定一遍了。<Cmd>wincmd 在 terminal 模式下可以直接执行，
  --  不需要先 <C-\><C-n> 退出终端模式。
  --
  --  See `:help wincmd` for a list of all window commands
  vim.keymap.set({ 'n', 'v', 't', 'i', 'c' }, '<C-h>', '<Cmd>wincmd h<CR>', { desc = 'Move focus to the left window' })
  vim.keymap.set({ 'n', 'v', 't', 'i', 'c' }, '<C-l>', '<Cmd>wincmd l<CR>', { desc = 'Move focus to the right window' })
  vim.keymap.set({ 'n', 'v', 't', 'i', 'c' }, '<C-j>', '<Cmd>wincmd j<CR>', { desc = 'Move focus to the lower window' })
  vim.keymap.set({ 'n', 'v', 't', 'i', 'c' }, '<C-k>', '<Cmd>wincmd k<CR>', { desc = 'Move focus to the upper window' })

  -- Disable q to prevent accidental macro recording (use Q instead)
  vim.keymap.set('n', 'q', '<Nop>', { desc = 'Disable q (use Q for recording)' })

  -- Insert mode word navigation
  vim.keymap.set('i', '<M-f>', '<C-o>w', { desc = 'Jump forward one word' })

  -- Yank last message block to clipboard
  vim.keymap.set('n', '<leader>ym', function()
    local lines = vim.split(vim.fn.execute('messages'), '\n')
    local last = #lines
    while last >= 1 and lines[last] == '' do
      last = last - 1
    end
    local first = last
    while first >= 2 and lines[first - 1] ~= '' do
      first = first - 1
    end
    if first > last then return end
    local cap = math.min(last, first + 4)
    local block = table.concat(vim.list_slice(lines, first, cap), '\n')
    vim.fn.setreg('+', block)
    vim.notify('Copied ' .. (cap - first + 1) .. '/' .. (last - first + 1) .. ' lines', vim.log.levels.INFO)
  end, { desc = 'Yank last message block' })

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end


-- ============================================================
-- SECTION 4: PLUGINS
-- All plugin configurations live in lua/custom/plugins/
-- ============================================================
do
  require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
