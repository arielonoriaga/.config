let g:rigel_airline = 1


let g:copilot_no_tab_map = v:true

let g:indentLine_char = '|'
let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2
let g:indentLine_enabled = 1

let g:rainbow_active = 1
let g:solarized_termcolors=256

let g:tokyonight_enable_italic = 0
let g:tokyonight_style = 'storm' " available: night, storm

let g:javascript_plugin_flow = 1

let g:NERDAltDelims_java = 1
let g:NERDCommentEmptyLines = 1
let g:NERDCompactSexyComs = 1
let g:NERDCreateDefaultMappings = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDDefaultAlign = 'right'
let g:NERDSpaceDelims = 1
let g:NERDToggleCheckAllLines = 1


let g:NERDTrimTrailingWhitespace = 1

let g:blamer_delay = 250
let g:blamer_enabled = 1
let g:blamer_prefix = ' >> '

let g:afterglow_blackout = 1

let g:used_javascript_libs = 'underscore,backbone,vue,jquery'

let g:everforest_background = 'soft'

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

let ayucolor="dark"

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

let g:coc_global_extensions = ['coc-tsserver', 'coc-json']

let g:coc_filetype_map = {
\ 'typescript.jsx': 'typescriptreact',
\ 'typescript.tsx': 'typescriptreact',
\ }

let g:vim_vue_plugin_config = {
\'syntax': {
\   'template': ['html'],
\   'script': ['javascript', 'typescript'],
\   'style': ['css', 'scss', 'sass'],
\},
\'full_syntax': [],
\'initial_indent': ['yaml'],
\'attribute': 1,
\'keyword': 1,
\'foldexpr': 0,
\'debug': 0,
\}

let g:floaterm_height = 0.9
let g:floaterm_width = 0.9

silent! call setwinvar(win, '&winhighlight', 'Normal:')
