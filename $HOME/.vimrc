execute pathogen#infect()

syntax on

colorscheme solarized
set background=dark

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

highlight CursorLine guibg=#444030
set cursorline

highlight CursorLineNR cterm=NONE guibg=#444030 guifg=#DDD7B9
highlight LineNr guibg=#777755 guifg=#545040
set number

highlight Visual guibg=#DDD7B9 guifg=#006B6B

"Filetype
set filetype=on
filetype plugin indent on

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
set hlsearch

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
"let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
"let &t_EI = "\<esc>[2 q" " block cursor for normal mode
"let &t_SR = "\<esc>[3 q" " underline cursor for replace mode

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
"https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
"https://vi.stackexchange.com/a/14203
if exists('$TMUX')
  let &t_SI = "\ePtmux;\e\e[6 q\e\\"
  let &t_EI = "\ePtmux;\e\e[2 q\e\\"
else
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
endif
autocmd InsertEnter,InsertLeave * set cul!
"https://vi.stackexchange.com/a/20220
set ttimeoutlen=10

" Unsets the "last search pattern" register by hitting return
" https://stackoverflow.com/a/662914
nnoremap <silent> <CR> :nohlsearch<CR><CR>
