let g:rigel_airline = 1

let g:airline_powerline_fonts = 1
let g:airline_theme = 'molokai'

let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeWinPos = "left"

let g:ale_pattern_options = {
\ '\.php$': { 'ale_enabled': 0 },
\}
let g:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
\ 'javascript': ['eslint'],
\ 'typescript': ['eslint'],
\ 'vue': ['eslint'],
\}
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

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

let g:tokyonight_enable_italic = 1
let g:tokyonight_style = 'night' " available: night, storm

let g:javascript_plugin_flow = 1

let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_width = 10

let g:NERDAltDelims_java = 1
let g:NERDCommentEmptyLines = 1
let g:NERDCompactSexyComs = 1
let g:NERDCreateDefaultMappings = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDTrimTrailingWhitespace = 1

let g:blamer_delay = 250
let g:blamer_enabled = 1
let g:blamer_prefix = ' >> '

let g:afterglow_blackout = 1

highlight Blamer guifg=lightgrey
