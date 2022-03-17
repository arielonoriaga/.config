nmap <c-n> :Startify<cr>
nmap <silent> <C-g> :NERDTreeFind<CR>
nmap <silent> <C-u> :NERDTreeToggle<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent>st <plug>(easymotion-s2)
nmap M <Plug>NERDCommenterToggle
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
noremap <silent>; :GFiles<cr>
noremap <silent>gs :CocSearch
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

vmap M <Plug>NERDCommenterToggle

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

:nmap <silent>cw yiw
:nnoremap <silent>ciw "_ciw
:nnoremap <silent>cl Vy
:nnoremap <silent>dd "_dd<cr>
nmap <C-d> :bd!<cr>
nmap <C-i> :bn<cr>
nmap <silent>cfn :let @+=expand('%:t:r')<cr>
nmap <silent>ctn :let @+=expand('%:t:r:r')<cr>
nmap <silent>dts :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>
nmap <silent>fn :let @+=expand('%:t:r')<cr> ;
nmap <silent>sf cw ;
nmap <silent>sw *
nmap <silent>t %
nmap U <C-W>>
nmap Y <C-W><
nnoremap <silent><C-[> <<
nnoremap <silent><C-]> >>
nnoremap <silent>J :m.+1<cr>gv=gv
noremap <c-f> :FindByContent<CR>
noremap <silent>' :History<cr>

vmap <silent><C-[> <<<Esc>
vmap <silent><C-]> >><Esc>
vmap <silent><C-l> :sort<cr>
vmap <silent>cl yI<cr><esc>kiconsole.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>
vmap <silent>t %
vnoremap <silent>J :m '>+1<cr>gv=gv
vnoremap <silent>K :m '<-2<cr>gv=gv
vnoremap <silent>K :m.-2<cr>gv=gv

let mapleader = ","
nmap <leader>diff <Plug>(GitGutterPreviewHunk)
nmap <leader>dl cl<silent>p
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>r :NERDTreeFocus<cr>R<c-w><c-p>
nmap <leader>rcw yiw :%s/
nmap <leader>ro :so ~/.config/nvim/init.vim<cr>
nmap <leader>ts :set tabstop=2<cr>:set shiftwidth=2<cr>
nmap <leader>v <C-w>v<cr>
nmap <leader>vue :set syntax=vue<cr>
nnoremap <silent> <leader>lg :LazyGit<CR>
noremap <leader>crp :let @+=expand("%")<cr>
noremap <leader>crpt :let @+=expand("%:r:r")<cr>
noremap <leader>gst :GFiles?<cr>
noremap <leader>reload :source ~/.vimrc<cr>
noremap <leader>rs :noh<cr>
noremap <leader>vim :source %<cr>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --smart-case --column --hidden --line-number --no-heading --color=always %s --glob "!{node_modules}" || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, "down:50%"), a:fullscreen)
endfunction

command! -nargs=* -bang FindByContent call RipgrepFzf(<q-args>, <bang>0)
