-- dotenv.nvim: load .env files and expose variables to the current vim session
vim.pack.add { 'https://github.com/ellisonleao/dotenv.nvim' }

require('dotenv').setup {
  enable_on_load = true, -- auto-load .env in cwd on startup
  verbose = false,
}
