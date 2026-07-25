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
