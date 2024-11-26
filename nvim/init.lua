require('maps')

vim.g.mapleader = ','

-- Load other configs
vim.cmd('so ~/.config/nvim/global.vim')
vim.cmd('so ~/.config/nvim/autos.vim')
vim.cmd('so ~/.config/nvim/maps.vim')
-- vim.cmd('so ~/.config/nvim/sets.vim')
vim.cmd('so ~/.config/nvim/snippets.vim')
vim.cmd('so ~/.config/nvim/ident.vim')
-- Replace this with Lua plugin setup
require('plugins')
require('config')
require('sets')
require('plugin_config')

vim.cmd('so ~/.vimrc')
