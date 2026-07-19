vim.pack.add {
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

require('render-markdown').setup {
  latex = { enabled = false },
}

-- render-markdown 在 buffer 编辑后可能用过期的 treesitter 节点调用 get_node_text，
-- 触发 "Index out of bounds"。直接重写 View:nodes，pcall 保护 Node 构造。
local Node = require('render-markdown.lib.node')
local View = require('render-markdown.request.view')
function View:nodes(root, query, callback)
  self:query(root, query, function(id, ts_node)
    if not ts_node:has_error() then
      local capture = query.captures[id]
      local ok, node = pcall(Node.new, self.buf, ts_node)
      if ok and node then
        callback(capture, node)
      end
    end
  end)
end

-- 用 virt_text overlay 遮盖密码，不依赖 conceallevel
local pw_ns = vim.api.nvim_create_namespace('markdown_pw')

local function conceal_pw(buf)
  vim.api.nvim_buf_clear_namespace(buf, pw_ns, 0, -1)
  -- 插入模式下显示明文，方便编辑
  if vim.fn.mode():find('^i') then return end
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local _, e = line:find('[Pp]assword:%s+')
    if e then
      local pw_len = vim.api.nvim_strwidth(line:sub(e + 1))
      vim.api.nvim_buf_set_extmark(buf, pw_ns, i - 1, e, {
        end_col = #line,
        virt_text = { { string.rep('•', pw_len) } },
        virt_text_pos = 'overlay',
      })
    end
  end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged' }, {
  pattern = '*.md',
  callback = function(ev) conceal_pw(ev.buf) end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*.md',
  callback = function(ev) vim.api.nvim_buf_clear_namespace(ev.buf, pw_ns, 0, -1) end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*.md',
  callback = function(ev) conceal_pw(ev.buf) end,
})

-- render-markdown 只需 treesitter parser，不需 highlighter
-- highlighter 的 markdown query 会用 conceal_lines 强制隐藏 ``` 行
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'markdown',
--   callback = function(ev) vim.treesitter.stop(ev.buf) end,
-- })
