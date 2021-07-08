source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/plug-config/coc.vim

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

so ~/.vimrc
so ~/.config/nvim/maps/maps.vim
so ~/.config/nvim/snippets/snippets.vim

colorscheme ayu

set t_Co=256

if (has("termguicolors"))
   set termguicolors
endif

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

set encoding=UTF-8
set tabstop=2
set shiftwidth=4
set expandtab
set hidden

autocmd CursorHold * silent call CocActionAsync('highlight')

let g:indentLine_char = '|'
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2

let g:ale_fix_on_save = 1

let g:solarized_termcolors=256

let g:blamer_enabled = 1

let g:airline_powerline_fonts = 1
let g:airline_theme='ayu'

let g:rainbow_active = 1

let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1

let g:vim_vue_plugin_load_full_syntax = 1
let g:vim_vue_plugin_use_typescript = 1
let g:vim_vue_plugin_highlight_vue_attr = 1
let g:vim_vue_plugin_highlight_vue_keyword = 1

let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name

