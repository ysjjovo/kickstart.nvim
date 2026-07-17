-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in the plugins directory and load them.
-- pcall 保护：单个插件出错不影响其余插件加载。
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' and not file_name:match '^_' then
    local module = file_name:gsub('%.lua$', '')
    local ok, err = pcall(require, 'custom.plugins.' .. module)
    if not ok then
      vim.notify('[plugins] Failed to load ' .. module .. ':\n' .. err, vim.log.levels.WARN)
    end
  end
end
