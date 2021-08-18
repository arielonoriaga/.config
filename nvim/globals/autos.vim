autocmd CursorHold * silent call CocActionAsync('highlight')
autocmd InsertEnter,InsertLeave * set cul!

autocmd FileType php,vue :set tabstop=4 shiftwidth=4
autocmd FileType typescript,javascript :set tabstop=2 shiftwidth=2
