#!/bin/bash
# lazygit editCommand: 通过 RPC 在父 Neovim 中编辑，阻塞直到完成
if [ -z "$NVIM" ]; then
  nvim "+${2:-1}" "$1"
  exit $?
fi

flag=$(mktemp -u)
nvim --server "$NVIM" --remote-expr "v:lua.require('lazygit_edit').open('$1', ${2:-1}, '$flag')"

while [ ! -f "$flag" ]; do sleep 0.1; done
rm -f "$flag"
