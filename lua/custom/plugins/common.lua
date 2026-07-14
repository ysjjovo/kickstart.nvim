-- Custom common settings & Custom keymap overrides for Neovim built-in behaviors
-- This file collects all native keybinding customizations in one place.

-- ============================================================
-- Blackhole register mappings
-- Prevent c/d operations from overwriting the clipboard (system or default register).
-- When you DO want to "cut" (delete and keep in clipboard), use: "+d or "+c
-- ============================================================

-- Normal mode: change operations go to blackhole
-- vim.keymap.set('n', 'c', '"_c', { desc = 'Change (blackhole)' })
-- vim.keymap.set('n', 'C', '"_C', { desc = 'Change to EOL (blackhole)' })
-- vim.keymap.set('n', 'cc', '"_cc', { desc = 'Change line (blackhole)' })

-- Normal mode: delete operations go to blackhole
-- vim.keymap.set('n', 'd', '"_d', { desc = 'Delete (blackhole)' })
-- vim.keymap.set('n', 'D', '"_D', { desc = 'Delete to EOL (blackhole)' })
-- vim.keymap.set('n', 'dd', '"_dd', { desc = 'Delete line (blackhole)' })
-- vim.keymap.set('n', 'x', '"_x', { desc = 'Delete char (blackhole)' })

-- Visual mode: change and delete go to blackhole
-- vim.keymap.set('x', 'c', '"_c', { desc = 'Change (blackhole)' })
-- vim.keymap.set('x', 'd', '"_d', { desc = 'Delete (blackhole)' })

-- Visual mode: paste without overwriting register
-- vim.keymap.set('x', 'p', '"_dP', { desc = 'Paste without yanking replaced text' })

-- ============================================================
-- Recording (macro) remap
-- Use Q to start/stop recording, avoids accidental triggers with q
-- ============================================================
vim.keymap.set('n', 'q', '<Nop>', { desc = 'Disable q (use Q for recording)' })
-- vim.keymap.set('n', 'Q', 'q', { desc = 'Record macro' })

-- ============================================================
-- Horizontal scrolling
-- Scroll the screen sideways by half a screen (efficient wide-line navigation)
-- ============================================================
-- vim.keymap.set('n', 'L', 'zL', { desc = 'Scroll right half screen' })
-- vim.keymap.set('n', 'H', 'zH', { desc = 'Scroll left half screen' })

-- ============================================================
-- Insert mode word navigation
-- ============================================================
vim.keymap.set('i', '<M-f>', '<C-o>w', { desc = 'Jump forward one word' })
vim.opt.guicursor = {
  "n-v-c:block-blinkwait700-blinkon400-blinkoff400",
  "i-ci-ve:ver25-blinkwait700-blinkon400-blinkoff400",
  "r-cr:hor20-blinkwait700-blinkon400-blinkoff400",
  "o:hor50-blinkwait700-blinkon400-blinkoff400",
  "t:ver25-blinkwait700-blinkon400-blinkoff400",
}

vim.keymap.set('n', '<leader>ym', function()
  local lines = vim.split(vim.fn.execute('messages'), '\n')
  for i = #lines, 1, -1 do
    if lines[i] ~= '' then
      vim.fn.setreg('+', lines[i])
      vim.notify('Copied: ' .. lines[i], vim.log.levels.INFO)
      return
    end
  end
end, { desc = 'Yank last message' })
