vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinLeave', 'FocusLost' }, {
  callback = function()
    vim.fn.jobstart('im-select com.apple.keylayout.ABC')
  end,
})
