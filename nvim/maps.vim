nnoremap <silent><F12> :FloatermToggle --name=cmd<CR>
tnoremap <silent><F12> <C-\><C-n>:FloatermToggle --name=cmd<CR>

let g:floaterm_height = 0.9
let g:floaterm_width = 0.9
let g:floaterm_autoclose = 2

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
