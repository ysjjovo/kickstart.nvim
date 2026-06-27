-- Blackhole register mappings
-- Prevent c/d operations from overwriting the clipboard (system or default register).
-- This way, yanked or externally copied content stays intact after change/delete operations.
-- When you DO want to "cut" (delete and keep in clipboard), use: "+d or "+c

-- Normal mode: change operations go to blackhole
vim.keymap.set('n', 'c', '"_c', { desc = 'Change (blackhole)' })
vim.keymap.set('n', 'C', '"_C', { desc = 'Change to EOL (blackhole)' })
vim.keymap.set('n', 'cc', '"_cc', { desc = 'Change line (blackhole)' })

-- Normal mode: delete operations go to blackhole
vim.keymap.set('n', 'd', '"_d', { desc = 'Delete (blackhole)' })
vim.keymap.set('n', 'D', '"_D', { desc = 'Delete to EOL (blackhole)' })
vim.keymap.set('n', 'dd', '"_dd', { desc = 'Delete line (blackhole)' })
vim.keymap.set('n', 'x', '"_x', { desc = 'Delete char (blackhole)' })

-- Visual mode: change and delete go to blackhole
vim.keymap.set('x', 'c', '"_c', { desc = 'Change (blackhole)' })
vim.keymap.set('x', 'd', '"_d', { desc = 'Delete (blackhole)' })

-- Visual mode: paste without overwriting register
vim.keymap.set('x', 'p', '"_dP', { desc = 'Paste without yanking replaced text' })
