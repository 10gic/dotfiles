#!/bin/bash

_make_link ()
{
    if [ ${#@} -ne 2 ]; then
        echo "Usage: _make_link soure target" 1>&2
        return
    fi
    local source="$1"
    local target="$2"
    if [[ ( ! -a "$target" ) || -L "$target" ]]; then
        # if target does not exist or target is symbolic link, just update it
        rm -f "${target}"
        ln -s "${source}" "${target}"
    else
        echo "${target} exists (and it's not a symbolic link), you must update it manually." 1>&2
    fi
}

FILE_LIST="
bashrc
utils.sh
perllib
vimrc
emacs
ctags
"

for file in $FILE_LIST; do
    ## example: bashrc ----> ${HOME}/.bashrc
    _make_link "${PWD}/${file}" "${HOME}/.${file}"
done

# make link for zshrc only zsh is avaiable
if command -v zsh >/dev/null 2>&1; then
    _make_link "${PWD}/zshrc" "${HOME}/.zshrc"
fi

# make link for kshrc only ksh is avaiable
if command -v ksh >/dev/null 2>&1; then
    _make_link "${PWD}/kshrc" "${HOME}/.kshrc"
fi

# make link for gdbinit only gdb is avaiable
if command -v gdb >/dev/null 2>&1; then
    _make_link "${PWD}/gdbinit" "${HOME}/.gdbinit"
fi

# update utils in ./bin/
mkdir -p "${HOME}/bin"
for util in bin/*; do
    chmod u+x "${PWD}/${util}"
    _make_link "${PWD}/${util}" "${HOME}/${util}"
done
