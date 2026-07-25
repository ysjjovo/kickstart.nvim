-- snacks.nvim: folke 的 QoL 小工具合集。
-- 模块化设计：只有在 setup 里「写出来」的模块才启用，没写的保持关闭。
-- 这里刻意只开「现有配置没有替代品」的模块，重叠的（picker→telescope、
-- explorer→yazi、lazygit→toggleterm、terminal→toggleterm）一律不列。

vim.pack.add {
  'https://github.com/folke/snacks.nvim',
}

require('snacks').setup {
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
  terminal = {
    -- 当有多个相同位置的 split 终端时，将它们堆叠（层叠）在一起
    stack = true,
    win = {
      keys = {
        term_normal = { '<Esc>', '<C-\\><C-n>', mode = 't', desc = 'Exit terminal mode' },
      },
    },
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
