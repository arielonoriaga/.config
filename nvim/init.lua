vim.loader.enable()

vim.g.mapleader = ','

require('plugins')
require('plugin_config')

require('config')
require('maps')
require('sets')

vim.cmd('so ~/.config/nvim/maps.vim')
vim.cmd('so ~/.vimrc')

-- vim.lsp.set_log_level("debug")
vim.cmd("highlight ColorColumn guibg=#533c5b")
