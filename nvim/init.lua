-- Replace this with Lua plugin setup
require('config')
require('maps')
require('plugin_config')
require('plugins')
require('sets')

local g = vim.g

g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

g.mapleader = ','

-- Load other configs
vim.cmd('so ~/.config/nvim/autos.vim')
vim.cmd('so ~/.config/nvim/maps.vim')

vim.cmd('so ~/.vimrc')
