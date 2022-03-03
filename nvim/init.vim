so ~/.config/nvim/autos.vim
so ~/.config/nvim/global.vim
so ~/.config/nvim/maps.vim
so ~/.config/nvim/sets.vim
so ~/.config/nvim/snippets.vim
so ~/.config/nvim/vim-plug/plugins.vim
so ~/.vimrc

set runtimepath^=~/.vimrc runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin on

set t_Co=256

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

colorscheme srcery
let g:airline_theme = 'google_dark'
