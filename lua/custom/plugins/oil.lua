-- oil.nvim: edit your filesystem like a buffer
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

-- 无法在 Neovim 中编辑的文件，按回车时用系统默认程序打开
local external_exts = {
  'pdf', 'csv', 'xlsx', 'xls', 'docx', 'doc', 'pptx', 'ppt',
  'zip', 'rar', '7z', 'tar', 'gz',
  'png', 'jpg', 'jpeg', 'gif', 'bmp', 'svg', 'webp',
  'mp4', 'mkv', 'avi', 'mov', 'mp3', 'flac', 'wav',
}
local external_set = {}
for _, ext in ipairs(external_exts) do external_set[ext] = true end

require('oil').setup {
  default_file_explorer = true,
  columns = { 'icon' },
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ['<CR>'] = function()
      local oil = require('oil')
      local entry = oil.get_cursor_entry()
      if entry and entry.type == 'file' then
        local ext = entry.name:match('%.([^%.]+)$')
        if ext and external_set[ext:lower()] then
          local path = oil.get_current_dir() .. entry.name
          vim.ui.open(path)
          return
        end
      end
      oil.select()
    end,
    ['q'] = 'actions.close',
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ["yr"] = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      if entry then
        local dir = oil.get_current_dir()
        local rel = vim.fn.fnamemodify(dir .. entry.name, ":.")
        vim.fn.setreg("+", rel)
        vim.notify("copy relative path: " .. rel, vim.log.levels.INFO)
      end
    end,
    ["yf"] = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      if entry then
        vim.fn.setreg("+", entry.name)
        vim.notify("copy filename: " .. entry.name, vim.log.levels.INFO)
      end
    end,
    -- 复制当前选中文件的绝对路径
    ["ya"] = function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      if entry then
        local dir = oil.get_current_dir()
        local abs_path = dir .. entry.name
        vim.fn.setreg("+", abs_path)
        vim.notify("copy absolute path: " .. abs_path, vim.log.levels.INFO)
      end
    end,
  },
}

vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory (Oil)' })
vim.keymap.set('n', '_', '<Cmd>Oil .<CR>', { desc = 'Open CWD (Oil)' })

local function copy_entry_path(fmt)
  local oil = require 'oil'
  local entry = oil.get_cursor_entry()
  if not entry then return end
  local full = oil.get_current_dir() .. entry.name
  local result = vim.fn.fnamemodify(full, fmt)
  vim.fn.setreg('+', result)
  vim.notify(result, vim.log.levels.INFO)
end

-- vim.keymap.set('n', 'yp', function() copy_entry_path ':.' end, { desc = 'Oil: copy relative path' })
-- vim.keymap.set('n', 'yP', function() copy_entry_path ':p' end, { desc = 'Oil: copy absolute path' })
-- vim.keymap.set('n', 'yn', function() copy_entry_path ':t' end, { desc = 'Oil: copy filename' })
