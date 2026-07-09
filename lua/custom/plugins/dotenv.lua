-- dotenv: load .env files for vim-dadbod-ui DB_UI_ prefix auto-detection
-- NOTE: vim-dadbod-ui specifically integrates with tpope/vim-dotenv (not ellisonleao/dotenv.nvim)
vim.pack.add { 'https://github.com/tpope/vim-dotenv' }

-- tpope/vim-dotenv does not auto-load; pull in the cwd's .env on startup and on cd.
-- Dotenv! (with bang) overrides existing env vars with the .env values.
vim.api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  callback = function()
    if vim.fn.filereadable '.env' == 1 then
      vim.cmd 'Dotenv! .env'
    end
  end,
})
