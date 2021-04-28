syntax on

autocmd InsertEnter,InsertLeave * set cul!
set clipboard=unnamed
set rnu
set number
set relativenumber
set smartindent
set nowrap
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set noerrorbells
set tabstop=4
set et
set sts=4
set showcmd
set numberwidth=1
set encoding=utf-8
set showmatch
set laststatus=2

set colorcolumn=120
highlight ColorColumn ctermbg=0 guibg=lightgreky
highlight ExtraWhitespace ctermbg=red guibg=red

let skip_defaults_vim=1
set viminfo=""

set background=dark

" Fix files with prettier, and then ESLint.
let b:ale_fixers = ['prettier', 'eslint']
" Equivalent to the above.
let b:ale_fixers = {'javascript': ['prettier', 'eslint']}
