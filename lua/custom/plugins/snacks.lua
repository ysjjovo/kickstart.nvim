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
  -- 启动欢迎页（只在无文件参数打开 nvim 时显示）
  -- 去掉默认的 startup 段：它依赖 lazy.nvim 的 lazy.stats，而本配置用 vim.pack，会报错。
--  dashboard = {
--    sections = {
--      { section = 'header' },
--      { section = 'keys', gap = 1, padding = 1 },
--    },
--  },
  -- 专注模式：zen 居中单窗，dim 暗化非当前作用域
  zen = {},
  dim = {},
  -- 在浏览器打开当前行对应的 git 远端 URL
  gitbrowse = {},
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
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(vim.lsp.status(), "info", {
      id = "lsp_progress",
      title = "LSP Progress",
      opts = function(notif)
        notif.icon = ev.data.params.value.kind == "end" and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

vim.keymap.set('n', '<leader>uz', function() Snacks.zen() end, { desc = 'Toggle [Z]en mode' })
vim.keymap.set('n', '<leader>bs', function() Snacks.scratch() end, { desc = 'Toggle [S]cratch buffer' })
vim.keymap.set('n', '<leader>un', function() Snacks.notifier.show_history() end, { desc = 'Toogle [N]otifier history' })
