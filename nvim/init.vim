source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/plug-config/coc.vim

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin on

so ~/.vimrc
so ~/.config/nvim/maps/maps.vim
so ~/.config/nvim/snippets/snippets.vim

set t_Co=256

if (has("termguicolors"))
   set termguicolors
endif

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

autocmd FileType typescript :set tabstop=2 shiftwidth=2
autocmd FileType javascript :set tabstop=2 shiftwidth=2
autocmd FileType vue :set tabstop=4 shiftwidth=4
autocmd FileType php :set tabstop=4 shiftwidth=4
autocmd CursorHold * silent call CocActionAsync('highlight')

set encoding=UTF-8
set tabstop=2
set shiftwidth=4
set expandtab
set hidden

colorscheme onedark

let g:rigel_airline = 1

let g:airline_powerline_fonts = 1
let g:airline_theme = 'ayu'

let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeWinPos = "right"

let g:ale_fix_on_save = 1
let g:ale_pattern_options = {'\.php$': {'ale_enabled': 0}}
let g:ale_fixers = {
\    'javascript': ['eslint'],
\    'typescript': ['eslint'],
\    'vue': ['eslint'],
\}

let g:blamer_enabled = 1

let g:indentLine_char = '|'
let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2
let g:indentLine_enabled = 1

let g:rainbow_active = 1
let g:solarized_termcolors=256

let g:vim_vue_plugin_highlight_vue_attr = 1
let g:vim_vue_plugin_highlight_vue_keyword = 1
let g:vim_vue_plugin_load_full_syntax = 1
let g:vim_vue_plugin_use_typescript = 1

let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

let g:javascript_plugin_flow = 1

" let g:minimap_highlight = 'MinimapCurrentLine'
let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1

" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
