-- snacks.nvim: folke 的 QoL 小工具合集。
-- 模块化设计：只有在 setup 里「写出来」的模块才启用，没写的保持关闭。

vim.pack.add {
  'https://github.com/folke/snacks.nvim',
}

require('snacks').setup {
  animate = {},
  -- 大文件打开时自动关掉重特性，防卡
  bigfile = {},
  -- 更快的文件打开路径（延后语法等，配合 bigfile）
  quickfile = {},
  -- 平滑滚动
  scroll = {},
  -- 通知 UI 美化（接管 vim.notify）
  notifier = {},
  -- 更好看的 vim.ui.input 浮窗输入框
  input = {},
  -- 专注模式：zen 居中单窗，dim 暗化非当前作用域
  zen = {},
  dim = {},
  -- 临时草稿 buffer
  scratch = {},
  image = {},
  -- 缩进参考线，替代 indent-blankline
  indent = {},
  -- 行号栏美化（折叠标记、git signs 等整合）
  statuscolumn = {},
  -- 树形文件浏览器，替代 oil
  explorer = {},
  -- lazygit 集成，替代 lazygit.nvim
  lazygit = {
    win = {
      keys = {
        -- 让 esc 透传给 lazygit，避免 commit message 时误退出终端模式
        term_normal = { '<esc>', '<esc>', mode = 't' },
      },
    },
  },
  -- 关闭 buffer 时保持窗口布局，替代 mini.bufremove
  bufdelete = {},
  -- 按需性能分析，不自动启动（:lua Snacks.profiler.toggle()）
  profiler = { enabled = false },
  -- LSP rename 时自动更新引用文件路径
  rename = {},
  -- 光标下单词高亮 + 跳转，替代手写 document_highlight
  words = {},
  -- 终端管理，替代 toggleterm
  terminal = {
    win = {
      position = 'float',
      border = 'rounded',
      height = 0.8,
      width = 0.8,
      -- split 模式显示编号和进程名
      wo = { winbar = '%{b:snacks_terminal.id}: %{b:term_title}' },
      keys = {
        term_normal = { '<esc>', '<C-\\><C-n>', mode = 't', desc = 'Exit terminal mode' },
      },
    },
  },
  -- 替代 telescope，原生支持图片预览
  picker = {
    -- 接管 vim.ui.select（替代 telescope-ui-select）
    ui_select = true,
  },
}

-- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
-- local progress = vim.defaulttable()
-- vim.api.nvim_create_autocmd("LspProgress", {
--   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
--     if not client or type(value) ~= "table" then
--       return
--     end
--     local p = progress[client.id]
--
--     for i = 1, #p + 1 do
--       if i == #p + 1 or p[i].token == ev.data.params.token then
--         p[i] = {
--           token = ev.data.params.token,
--           msg = ("[%3d%%] %s%s"):format(
--             value.kind == "end" and 100 or value.percentage or 100,
--             value.title or "",
--             value.message and (" **%s**"):format(value.message) or ""
--           ),
--           done = value.kind == "end",
--         }
--         break
--       end
--     end
--
--     local msg = {} ---@type string[]
--     progress[client.id] = vim.tbl_filter(function(v)
--       return table.insert(msg, v.msg) or not v.done
--     end, p)
--
--     local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
--     vim.notify(table.concat(msg, "\n"), "info", {
--       id = "lsp_progress",
--       title = client.name,
--       opts = function(notif)
--         notif.icon = #progress[client.id] == 0 and " "
--           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
--       end,
--     })
--   end,
-- })

vim.keymap.set('n', '<leader>uz', function() Snacks.zen() end, { desc = 'Toggle [Z]en mode' })
vim.keymap.set('n', '<leader>bs', function() Snacks.scratch() end, { desc = 'Toggle [S]cratch buffer' })
vim.keymap.set('n', '<leader>un', function() Snacks.notifier.show_history() end, { desc = 'Toogle [N]otifier history' })

-- Explorer keymaps (替代 oil)
vim.keymap.set('n', '-', function() Snacks.explorer() end, { desc = 'Open file explorer' })

-- Lazygit keymaps
vim.keymap.set('n', '<leader>ug', function() Snacks.lazygit() end, { desc = 'Toggle Lazygit' })
vim.keymap.set('n', '<leader>ulf', function() Snacks.lazygit.log() end, { desc = 'Lazygit [F]ilter (project commits)' })
vim.keymap.set('n', '<leader>ulc', function() Snacks.lazygit.log { current_file = true } end, { desc = 'Lazygit [C]urrent file commits' })

-- Terminal keymaps (替代 toggleterm)
-- 共享终端实例，切换展示形式时关闭旧窗口用新位置重开
local term_position = 'float'

local function term_win_opts(pos)
  if pos == 'float' then
    return { position = 'float', height = 0.8, width = 0.8 }
  elseif pos == 'right' then
    return { position = 'right', width = 0.4 }
  else
    return { position = 'bottom', height = 0.3 }
  end
end

local function toggle_term()
  Snacks.terminal.toggle(nil, { win = term_win_opts(term_position) })
end

local function switch_position(pos)
  if pos == term_position then
    toggle_term()
    return
  end
  term_position = pos
  -- 找到已有终端实例并切换位置
  local terms = Snacks.terminal.list()
  for _, term in pairs(terms) do
    if term:win_valid() then
      term:hide()
      term.opts.position = pos
      if pos == 'float' then
        term.opts.height = 0.8
        term.opts.width = 0.8
      elseif pos == 'right' then
        term.opts.width = 0.4
        term.opts.height = nil
      else
        term.opts.height = 0.3
        term.opts.width = nil
      end
      vim.schedule(function() term:show() end)
    end
  end
end

vim.keymap.set('n', 't', toggle_term, { desc = 'Toggle Terminal' })
vim.keymap.set('n', 'T', function()
  local buf_dir = vim.fn.expand('%:p:h')
  Snacks.terminal.toggle(nil, { win = term_win_opts(term_position), cwd = buf_dir })
end, { desc = 'Toggle Terminal (buffer dir)' })
vim.keymap.set('n', '<leader>utf', function() switch_position('float') end, { desc = 'Terminal [F]loat' })
vim.keymap.set('n', '<leader>utv', function() switch_position('right') end, { desc = 'Terminal [V]ertical' })
vim.keymap.set('n', '<leader>uts', function() switch_position('bottom') end, { desc = 'Terminal horizontal [S]plit' })

-- Buffer delete keymaps (替代 mini.bufremove)
vim.keymap.set('n', 'q', function() Snacks.bufdelete() end, { desc = 'Buffer [D]elete' })
vim.keymap.set('n', '<leader>bw', function() Snacks.bufdelete.all() end, { desc = 'Buffer [W]ipeout all' })

-- Words: ]w / [w 跳转到下一个/上一个高亮单词
vim.keymap.set({ 'n', 't' }, ']]', function() Snacks.words.jump(1) end, { desc = 'Next word reference' })
vim.keymap.set({ 'n', 't' }, '[[', function() Snacks.words.jump(-1) end, { desc = 'Prev word reference' })

-- Picker keymaps (替代 telescope)
vim.keymap.set('n', '<leader>sh', function() Snacks.picker.help() end, { desc = 'Search [H]elp' })
vim.keymap.set('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Search [K]eymaps' })
vim.keymap.set('n', '<leader>sf', function() Snacks.picker.files() end, { desc = 'Search [F]iles' })
vim.keymap.set('n', '<leader>ss', function() Snacks.picker.pickers() end, { desc = 'Search [S]elect picker' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', function() Snacks.picker.grep_word() end, { desc = 'Search current [W]ord' })
vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Search by [G]rep' })
vim.keymap.set('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Search [D]iagnostics' })
vim.keymap.set('n', '<leader>sR', function() Snacks.picker.resume() end, { desc = 'Search Resume' })
vim.keymap.set('n', '<leader>sr', function() Snacks.picker.recent() end, { desc = 'Search [R]ecent Files' })
vim.keymap.set('n', '<leader>sc', function() Snacks.picker.commands() end, { desc = 'Search [C]ommands' })
vim.keymap.set('n', '<leader><leader>', function() Snacks.picker.buffers() end, { desc = 'Search existing buffers' })
vim.keymap.set('n', '<leader>/', function() Snacks.picker.lines() end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function() Snacks.picker.grep_buffers() end, { desc = 'Search [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Search [N]eovim files' })

-- LSP picker keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('snacks-picker-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    vim.keymap.set('n', 'grr', function() Snacks.picker.lsp_references() end, { buffer = buf, desc = 'Goto [R]eferences' })
    vim.keymap.set('n', 'gri', function() Snacks.picker.lsp_implementations() end, { buffer = buf, desc = 'Goto [I]mplementation' })
    vim.keymap.set('n', 'grd', function() Snacks.picker.lsp_definitions() end, { buffer = buf, desc = 'Goto [D]efinition' })
    vim.keymap.set('n', 'gO', function() Snacks.picker.lsp_symbols() end, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', function() Snacks.picker.lsp_workspace_symbols() end, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', function() Snacks.picker.lsp_type_definitions() end, { buffer = buf, desc = 'Goto [T]ype Definition' })
  end,
})
