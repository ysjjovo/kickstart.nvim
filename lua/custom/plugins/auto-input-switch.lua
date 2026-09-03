local gh = require('custom.plugins._util').gh

vim.pack.add { gh 'amekusa/auto-input-switch.nvim' }

require('auto-input-switch').setup({
  popup = { enable = false },
  normalize = {
    enable = true,
    on = { 'QuitPre', 'FocusLost', 'TermLeave' },
  },
  restore = {
    -- match 启用时建议关闭 restore，避免冲突
    enable = false,
  },
  match = {
    enable = true,
    languages = {
      Zh = { enable = true },
    },
  },
  os_settings = {
    macos = {
      normal_input = 'com.apple.keylayout.ABC',
      lang_inputs = {
        Zh = 'com.apple.inputmethod.SCIM.WBX',
      },
    },
  },
})
