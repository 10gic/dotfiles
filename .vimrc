source $VIMRUNTIME/vimrc_example.vim

" set format of status line
set statusline=
set statusline+=\ %h%1*%m%r%w%0* " flag
set statusline+=\ [%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding}, " encoding
set statusline+=%{&fileformat}] " file format
set statusline+=\ (%l/%L,%c)
set statusline+=\ 0x%02.2B " The hex of current char
set statusline+=\ \ %F "full path

" Displaying status line always
set laststatus=2
