vim.loader.enable()

-- Replace this with Lua plugin setup
require('plugins')
require('plugin_config')

require('config')
require('maps')
require('sets')

-- Load other configs
vim.cmd('so ~/.config/nvim/maps.vim')

vim.cmd('so ~/.vimrc')

vim.lsp.set_log_level("debug")
vim.cmd("highlight ColorColumn guibg=#3c3c3c")
