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

"Show existing tab with 4 spaces width
set tabstop=4
"When indenting with '>', use 4 spaces width
set shiftwidth=4
set softtabstop=4
set smarttab
"On pressing tab, insert 4 spaces
set expandtab
"set textwidth=79

set ignorecase

"set hlsearch

"python-mode
let g:pymode_folding = 0

"yaml files
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"Always show the status line
set laststatus=2
