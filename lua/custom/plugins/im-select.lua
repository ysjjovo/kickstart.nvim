vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    vim.fn.jobstart('im-select com.apple.keylayout.ABC')
  end,
})
