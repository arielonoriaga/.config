"Coc commands
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)

nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)

nmap U <C-W>>
nmap Y <C-W><

nmap M <Plug>NERDCommenterToggle
vmap M <Plug>NERDCommenterToggle
"Copia la linea
:nnoremap <silent>cl Vy
"Copia la palabra actual
:nmap <silent>cw yiw
"Borra los traling spaces
nmap <silent>dts :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>
"Busca referencias en todos los archivos
nmap <silent>ff ,cw ,gs
"Copia la palabra actual y abre FZF
nmap <silent>sf cw ;
"Borra la linea sin copiar
:nnoremap <silent>dd "_dd<cr>
:nnoremap <silent>ciw "_ciw
"Copia y busca la palabra actual
nmap <silent>sw *
"Moving lines like vscode
vnoremap <silent>J :m '>+1<cr>gv=gv
vnoremap <silent>K :m '<-2<cr>gv=gv
nnoremap <silent>J :m.+1<cr>gv=gv
vnoremap <silent>K :m.-2<cr>gv=gv
"Ident lines
nnoremap <silent><C-[> <<
nnoremap <silent><C-]> >>
vmap <silent><C-[> <<<Esc>
vmap <silent><C-]> >><Esc>
" Toggle nerdtree
:nnoremap <silent> <C-u> :NERDTreeToggle<CR>
" Show on tree
nnoremap <silent> <C-g> :NERDTreeFind<CR>
" Ale
nmap <silent> <C-a> :ALEToggle<cr>
" Ident Function
nnoremap <silent><C-m> >%
nnoremap <silent><C-n> <%

nnoremap <silent><C-l> :ALEFix<cr>
" Copia el nombre del archivo en el que estas y abre fzf
nmap <silent>fn :let @+=expand('%:t:r')<cr> ;
" Copia el nombre del archivo actual
nmap <silent>cfn :let @+=expand('%:t:r')<cr>
nmap <silent>ctn :let @+=expand('%:t:r:r')<cr>
" Moverse entre llaves
nmap <silent>t %
vmap <silent>t %
" Ordena las palabras
vmap <silent>l :sort<cr>
" Busar algun texto en el arbol de archivos
noremap <silent>gs :CocSearch
" Buscar Archivos
noremap <silent>; :GFiles<cr>
" Historial
noremap <silent>' :History<cr>
" Import
noremap <silent>ci :ALEImport<cr>

"Busca coincidencias
nmap <silent>st <plug>(easymotion-s2)

let mapleader = ","
"Git status
noremap <leader>gst :GFiles?<cr>
"Remueve ultima busqueda /
noremap <leader>rs :noh<cr>
"Recarga el archivo de vimrc donde sea que este
noremap <leader>reload :source ~/.vimrc<cr>
"Copia el relative path
noremap <leader>crp :let @+=expand("%")<cr>
noremap <leader>crpt :let @+=expand("%:r:r")<cr>
"Recarga haciendo referencia al archivo actual
noremap <leader>vim :source %<cr>
"split screen vertical
nmap <leader>v <C-w>v<cr>
"Copia la palabra actual y prepara para hacer un replace en todo el archivo
nmap <leader>rcw yiw :%s/
"Recarga nerdtree

nmap <leader>r :NERDTreeFocus<cr>R<c-w><c-p>
nmap <leader>dl cl<silent>p

nmap <leader>ts :set tabstop=2<cr>:set shiftwidth=2<cr>
nmap <leader>vue :set syntax=vue<cr>

nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>diff <Plug>(GitGutterPreviewHunk)
nmap <leader>ro :so ~/.config/nvim/init.vim<cr>

nnoremap <silent> <leader>lg :LazyGit<CR>

" Find: Find files by content
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --smart-case --column --hidden --line-number --no-heading --color=always %s --glob "!{node_modules}" || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, "down:50%"), a:fullscreen)
endfunction

command! -nargs=* -bang FindByContent call RipgrepFzf(<q-args>, <bang>0)

noremap <c-f> :FindByContent<CR>
