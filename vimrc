let basevimrc = $VIMRUNTIME . '/vimrc_example.vim'
if filereadable(basevimrc)
  source $VIMRUNTIME/vimrc_example.vim
endif

" set format of status line
set statusline=
set statusline+=\ %h%1*%m%r%w%0* " flag
set statusline+=\ [%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding}, " encoding
set statusline+=%{&fileformat}] " file format
set statusline+=\ (%l/%L,%c)
set statusline+=\ 0x%02.2B " The hex of current char
set statusline+=\ \ %F "full path

" change location of backup/undo/swp dir
" the tailing // of directory means that file names will be built from the complete path to the file (However, it does not work with backupdir)
set backupdir=$HOME/.vim/backup
set undodir=$HOME/.vim/undo//
set directory=$HOME/.vim/swp//
if !isdirectory($HOME.'/.vim/backup')
    call mkdir($HOME.'/.vim/backup', "p")
endif
if !isdirectory($HOME.'/.vim/undo')
    call mkdir($HOME.'/.vim/undo', "p")
endif
if !isdirectory($HOME.'/.vim/swp')
    call mkdir($HOME.'/.vim/swp', "p")
endif

" Displaying status line always
set laststatus=2
