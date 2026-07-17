# Neovim Config 规则

## 插件安装

- 插件文件放在 `lua/custom/plugins/` 目录下，每个插件一个文件
- 遵循最佳实践，最小化配置——如果某项配置已经是插件默认值，不要重复写出来
- 使用 `vim.pack.add` 安装插件（Neovim 内置包管理）

## 注释

- 关键配置项写注释，说明为什么这样配置
- 显而易见的配置不加注释

## 配置组织

- 通用配置（vim options、keymaps、autocmds 等）写在 `init.lua` 里
- 插件特定配置写在各自的插件文件中
