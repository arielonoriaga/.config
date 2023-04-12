require('maps')

vim.cmd('so ~/.config/nvim/global.vim')
vim.cmd('so ~/.config/nvim/autos.vim')
vim.cmd('so ~/.config/nvim/maps.vim')
vim.cmd('so ~/.config/nvim/sets.vim')
vim.cmd('so ~/.config/nvim/snippets.vim')
vim.cmd('so ~/.config/nvim/vim-plug/plugins.vim')
vim.cmd('so ~/.vimrc')

vim.cmd('colorscheme tokyonight')

vim.g.airline_theme = 'aurora'

-- function! AdaptColorscheme()
--    highlight clear CursorLine
--    highlight Normal ctermbg=none
--    highlight LineNr ctermbg=none
--    highlight Folded ctermbg=none
--    highlight NonText ctermbg=none
--    highlight SpecialKey ctermbg=none
--    highlight VertSplit ctermbg=none
--    highlight SignColumn ctermbg=none
-- endfunction
--
-- highlight Normal guibg=NONE ctermbg=NONE
-- highlight CursorColumn cterm=NONE ctermbg=NONE ctermfg=NONE
-- highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE
-- highlight CursorLineNr cterm=NONE ctermbg=NONE ctermfg=NONE
-- highlight clear LineNr
-- highlight clear SignColumn
-- highlight clear StatusLine
--
-- autocmd ColorScheme * call AdaptColorscheme()
-- autocmd InsertEnter * set nocursorline
-- autocmd InsertLeave * set nocursorline
--
-- set cursorline
-- set noshowmode
-- set nocursorline
