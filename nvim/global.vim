let g:rigel_airline = 1

let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeHighlightFoldersFullName = 0 " highlights the folder name
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

let g:tokyonight_enable_italic = 0
let g:tokyonight_style = 'storm' " available: night, storm

let g:javascript_plugin_flow = 1

let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_git_colors = 1
let g:minimap_highlight_search = 1
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

let g:used_javascript_libs = 'underscore,backbone,vue,jquery'

let g:everforest_background = 'hard'

let g:sonokai_style = 'andromeda'
let g:sonokai_disable_italic_comment = 1
let g:sonokai_enable_italic = 0

highlight Blamer guifg=lightgrey

let g:lazygit_floating_window_winblend = 0 " transparency of floating window
let g:lazygit_floating_window_scaling_factor = 0.9 " scaling factor for floating window

let g:fzf_layout = { 'down': '40%' }

let airline#extensions#tabline#current_first = 0
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t:r'
let g:airline#extensions#tabline#tabs_label = 't'
let g:airline_powerline_fonts = 1

let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''     : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ ''     : 'V',
    \ }

let g:startify_bookmarks = [
\ { 'C': '~/.config/' },
\ { 'P': '~/Projects/' },
\ ]
let g:startify_files_number = 20

let g:startify_center = 80

let g:startify_commands = [
\ ['Help', ':h startify'],
\ ['SDB - Up', '!cd ~/Projects/Wizards/SDBranch/ && make dev-up'],
\ ['SDB - Down', '!cd ~/Projects/Wizards/SDBranch/ && make dev-down'],
\ ]

let g:startify_lists = [
\ { 'type': 'commands'  },
\ { 'type': 'bookmarks' },
\ { 'type': 'files'     },
\ ]
