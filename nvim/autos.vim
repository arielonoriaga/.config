autocmd InsertEnter,InsertLeave * set cul!

function! OnChangeVueSyntax(syntax)
  echom 'Syntax is '.a:syntax
  if a:syntax == 'html'
    setlocal commentstring=<!--%s-->
    setlocal comments=s:<!--,m:\ \ \ \ ,e:-->
  elseif a:syntax =~ 'css'
    setlocal comments=s1:/*,mb:*,ex:*/ commentstring&
  else
    setlocal commentstring=//%s
    setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
  endif
endfunction

" autocmd CursorHold * silent call CocActionAsync('diagnosticHover')

" autocmd InsertEnter * call :NERDTreeClose<CR>
