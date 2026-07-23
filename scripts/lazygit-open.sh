#!/bin/bash
# lazygit openCommand: 在父 Neovim 主窗口打开文件，二进制/媒体走系统 open
file="$1"
ext="${file##*.}"
ext="${ext,,}"

case "$ext" in
  pdf|csv|xlsx|xls|docx|doc|pptx|ppt|\
  zip|rar|7z|tar|gz|\
  png|jpg|jpeg|gif|bmp|svg|webp|\
  mp4|mkv|avi|mov|mp3|flac|wav)
    open "$file"
    ;;
  *)
    if [ -n "$NVIM" ]; then
      nvim --server "$NVIM" --remote-expr "v:lua.require('lazygit_edit').open('$file')"
    else
      nvim "$file"
    fi
    ;;
esac
