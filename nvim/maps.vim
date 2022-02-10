nmap <silent> <C-u> :NERDTreeToggle<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent>st <plug>(easymotion-s2)
nmap M <Plug>NERDCommenterToggle
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap <silent> <C-g> :NERDTreeFind<CR>
vmap M <Plug>NERDCommenterToggle
noremap <silent>gs :CocSearch
noremap <silent>; :GFiles<cr>

:nmap <silent>cw yiw
:nnoremap <silent>ciw "_ciw
:nnoremap <silent>cl Vy
:nnoremap <silent>dd "_dd<cr>
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
vmap <silent>l :sort<cr>
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
