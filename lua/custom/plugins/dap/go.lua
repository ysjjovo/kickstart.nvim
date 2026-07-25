vim.pack.add { 'https://github.com/leoluz/nvim-dap-go' }

require('dap-go').setup {
  delve = { detached = vim.fn.has 'win32' == 0 },
}
