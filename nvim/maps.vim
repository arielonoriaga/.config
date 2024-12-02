nnoremap <silent><F12> :FloatermToggle --width=0.8<CR>
tnoremap <silent><F12> <C-\><C-n>:FloatermToggle<CR>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <leader>hi :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

let g:copilot_no_tab_map = v:true
