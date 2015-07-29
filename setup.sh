#!/usr/bin/env sh

_cp_into_home ()
{
    if [ -z "$1" ]; then
        return
    fi
    # backup old file
    if [ -a "${HOME}/$1" ]; then
        if [ -d "${HOME}/$1" ]; then
            rm -rf "${HOME}/$1.bk"
        fi
        mv "${HOME}/$1" "${HOME}/$1.bk"
    fi
    # copy it into HOME
    cp -rf "$1" "${HOME}/"
}

FILE_LIST="
.bashrc
.utils.sh
.perllib
"

for file in $FILE_LIST; do
    _cp_into_home $file
done

# first check zsh is avaiable
if command -v zsh >/dev/null 2>&1; then
    _cp_into_home .zshrc
fi

# first check gdb is avaiable
if command -v gdb >/dev/null 2>&1; then
    _cp_into_home .gdbinit
fi
