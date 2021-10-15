source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/plug-config/coc.vim

set runtimepath^=~/.vimrc runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin on

so ~/.config/nvim/globals/autos.vim
so ~/.config/nvim/globals/global.vim
so ~/.config/nvim/globals/sets.vim
so ~/.config/nvim/maps/maps.vim
so ~/.config/nvim/snippets/snippets.vim
so ~/.vimrc

set t_Co=256

if (has("termguicolors"))
   set termguicolors
endif

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

colorscheme sonokai
