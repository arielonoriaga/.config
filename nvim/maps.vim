nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent>st <plug>(easymotion-s2)
nmap M <Plug>NERDCommenterToggle
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap ga <Plug>(EasyAlign)
vmap M <Plug>NERDCommenterToggle
xmap ga <Plug>(EasyAlign)

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
nmap <silent>dts :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>

vmap <silent>cl yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>
vnoremap <silent>J :m '>+1<cr>gv=gv
vnoremap <silent>K :m '<-2<cr>gv=gv

let mapleader = ","
nmap <leader>diff <Plug>(GitGutterPreviewHunk)
nmap <leader>dl cl<silent>p
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>r :NERDTreeFocus<cr>R<c-w><c-p>
nmap <leader>rcw yiw :%s/
nmap <leader>ro :so ~/.config/nvim/init.vim<cr>
nmap <leader>v <C-w>v<cr>
nmap <leader>vue :set syntax=vue<cr>
nmap <leader>ts :set syntax=typescript<cr>
nnoremap <silent> <leader>lg :LazyGit<CR>
noremap <leader>crp :let @+=expand("%")<cr>
noremap <leader>crpt :let @+=expand("%:r:r")<cr>
noremap <leader>gst :GFiles?<cr>
noremap <leader>reload :source ~/.vimrc<cr>
noremap <leader>rs :noh<cr>
noremap <leader>vim :source %<cr>

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --smart-case --column --hidden --line-number --no-heading --color=always %s --glob "!{node_modules}" || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, "down:50%"), a:fullscreen)
endfunction

command! -nargs=* -bang FindByContent call RipgrepFzf(<q-args>, <bang>0)

nmap <leader>hi :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
