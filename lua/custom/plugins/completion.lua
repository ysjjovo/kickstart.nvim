local gh = require('custom.plugins._util').gh

vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    preset = 'enter',
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
    per_filetype = {
      sql = { 'lsp', 'path', 'snippets', 'dadbod' },
      mysql = { 'lsp', 'path', 'snippets', 'dadbod' },
      plsql = { 'lsp', 'path', 'snippets', 'dadbod' },
    },
    providers = {
      dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
    },
  },

  snippets = { preset = 'luasnip' },

  fuzzy = { implementation = 'lua' },

  signature = { enabled = true },
}
