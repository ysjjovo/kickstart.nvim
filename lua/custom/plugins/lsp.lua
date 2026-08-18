local gh = require('custom.plugins._util').gh

vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- snacks picker 版的 LSP 跳转（懒闭包，按键时才引用 Snacks，无加载顺序问题）
    map('grr', function() Snacks.picker.lsp_references() end, 'Goto [R]eferences')
    map('gri', function() Snacks.picker.lsp_implementations() end, 'Goto [I]mplementation')
    map('grd', function() Snacks.picker.lsp_definitions() end, 'Goto [D]efinition')
    map('grt', function() Snacks.picker.lsp_type_definitions() end, 'Goto [T]ype Definition')
    map('gO', function() Snacks.picker.lsp_symbols() end, 'Open Document Symbols')
    map('gW', function() Snacks.picker.lsp_workspace_symbols() end, 'Open Workspace Symbols')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method('textDocument/inlayHint', { bufnr = event.buf }) then
      map('<leader>uh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, 'Toggle Inlay [H]ints')
    end
  end,
})

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mfussenegger/nvim-jdtls',
}

-- 从 lsp/ 目录动态收集并启用所有 server
local lsp_dir = vim.fn.stdpath 'config' .. '/lsp'
local servers = {}
for name, type in vim.fs.dir(lsp_dir) do
  if type == 'file' and name:match '%.lua$' then
    table.insert(servers, (name:gsub('%.lua$', '')))
  end
end

vim.lsp.enable(servers)
