#!/bin/bash
# lazygit openCommand: 二进制/媒体文件走系统 open，其余用 nvim-remote 在当前实例打开

file="$1"
ext="${file##*.}"
ext="${ext,,}" # lowercase

case "$ext" in
  pdf|csv|xlsx|xls|docx|doc|pptx|ppt|\
  zip|rar|7z|tar|gz|\
  png|jpg|jpeg|gif|bmp|svg|webp|\
  mp4|mkv|avi|mov|mp3|flac|wav)
    open "$file"
    ;;
  *)
    if [ -n "$NVIM" ]; then
      nvim --server "$NVIM" --remote "$file"
    else
      open "$file"
    fi
    ;;
esac
