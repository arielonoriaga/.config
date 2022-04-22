so ~/.config/nvim/autos.vim
so ~/.config/nvim/global.vim
so ~/.config/nvim/maps.vim
so ~/.config/nvim/sets.vim
so ~/.config/nvim/snippets.vim
so ~/.config/nvim/vim-plug/plugins.vim
so ~/.vimrc

so ~/.config/nvim/transparent.vim

set runtimepath^=~/.vimrc runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin on

set t_Co=256

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

colorscheme srcery
let g:airline_theme = 'google_dark'

function! AdaptColorscheme()
   highlight clear CursorLine
   highlight Normal ctermbg=none
   highlight LineNr ctermbg=none
   highlight Folded ctermbg=none
   highlight NonText ctermbg=none
   highlight SpecialKey ctermbg=none
   highlight VertSplit ctermbg=none
   highlight SignColumn ctermbg=none
endfunction

highlight Normal guibg=NONE ctermbg=NONE
highlight CursorColumn cterm=NONE ctermbg=NONE ctermfg=NONE
highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE
highlight CursorLineNr cterm=NONE ctermbg=NONE ctermfg=NONE
highlight clear LineNr
highlight clear SignColumn
highlight clear StatusLine

autocmd ColorScheme * call AdaptColorscheme()
autocmd InsertEnter * set nocursorline
autocmd InsertLeave * set nocursorline

set cursorline
set noshowmode
set nocursorline
