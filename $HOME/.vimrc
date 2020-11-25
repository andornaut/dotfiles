"Start the pathogen plugin
execute pathogen#infect()

syntax on
"set background=light
set background=dark
colorscheme solarized

"Filetype
set filetype=on
filetype plugin indent on

"Show line number
set number

"Disable auto-indent"
set noautoindent

"Show column in status bar
set ruler

"Show existing tab with 4 spaces width
set tabstop=4
"When indenting with '>', use 4 spaces width
set shiftwidth=4
set softtabstop=4
set smarttab
"On pressing tab, insert 4 spaces
set expandtab
"set textwidth=79

"Ignore case while searching
set ignorecase
set smartcase

"Hightlight matched text while searching
set incsearch

"python-mode
let g:pymode_folding = 0
"Disable netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

"yaml files
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"Always show the status line
set laststatus=2

"Make insert mode more obvious
"https://stackoverflow.com/a/6489348
:autocmd InsertEnter,InsertLeave * set cul!
let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" " block cursor for normal mode
let &t_SR = "\<esc>[3 q" " underline cursor for replace mode
