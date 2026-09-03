local function switch_to_english()
  vim.fn.jobstart('im-select com.apple.keylayout.ABC')
end

-- ModeChanged catches all mode transitions, including double-Esc in terminal plugins
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = { 'i:*', 'R:*', 'ic:*', 'ix:*', 't:*' },
  callback = switch_to_english,
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinLeave', 'FocusLost', 'CmdlineEnter' }, {
  callback = switch_to_english,
})
