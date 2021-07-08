"Coc commands
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)

"Copia la linea
:nnoremap <silent>cl Vy
"Copia la palabra actual
:nmap <silent>cw yiw
"Borra los traling spaces
nmap <silent>dts :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>
"Busca referencias en todos los archivos
nmap <silent>ff ,cw ,gs
"Copia la palabra actual y abre FZF
nmap <silent>sf cw fs
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
nnoremap <silent> <C-t> :NERDTreeToggle<CR>
" Show on tree
nnoremap <silent> <C-g> :NERDTreeFind<CR>
"Ale
nmap <silent> <C-a> :ALEToggle<cr>
""Ident Function
nnoremap <silent><C-m> >%
nnoremap <silent><C-n> <%
"Copia el nombre del archivo en el que estas y abre fzf
nmap <silent>fn :let @+=expand('%:t:r')<cr> fs
"Copia el nombre del archivo actual
nmap <silent>cfn :let @+=expand('%:t:r')<cr>
nmap <silent>ctn :let @+=expand('%:t:r:r')<cr>
"Moverse entre llaves
nmap <silent>t %
vmap <silent>t %
"Ordena las palabras
vmap <silent>s :sort<cr>
"Busar algun texto en el arbol de archivos
noremap <silent>gs :CocSearch
"Buscar Archivos
noremap <silent>fs :GFiles<cr>
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
nmap <leader>tree :NERDTree<cr>
nmap <leader>dl cl<silent>p
"Historial
nmap <leader>h :History<cr>

nmap <leader>ts :set tabstop=2<cr>:set shiftwidth=2<cr>
nmap <leader>vue :set tabstop=4<cr>:set shiftwidth=4<cr>


