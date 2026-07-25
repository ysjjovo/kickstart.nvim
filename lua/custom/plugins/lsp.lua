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

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
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
