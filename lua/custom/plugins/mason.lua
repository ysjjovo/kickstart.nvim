local gh = require('custom.plugins._util').gh

vim.pack.add {
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {}

-- 从 lsp/ 目录动态收集 server 名
local lsp_dir = vim.fn.stdpath 'config' .. '/lsp'
local servers = {}
for name, type in vim.fs.dir(lsp_dir) do
  if type == 'file' and name:match '%.lua$' then
    table.insert(servers, (name:gsub('%.lua$', '')))
  end
end

local ensure_installed = vim.list_extend(vim.deepcopy(servers), {
  'stylua',
  'jdtls',
  'markdownlint',
  'shellcheck',
  'hadolint',
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }
