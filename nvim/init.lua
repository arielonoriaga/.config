require('maps')

vim.g.mapleader = ','

-- Load other configs
vim.cmd('so ~/.config/nvim/global.vim')
vim.cmd('so ~/.config/nvim/autos.vim')
vim.cmd('so ~/.config/nvim/maps.vim')
vim.cmd('so ~/.config/nvim/sets.vim')
vim.cmd('so ~/.config/nvim/snippets.vim')
vim.cmd('so ~/.config/nvim/ident.vim')
-- Replace this with Lua plugin setup
require('plugins')
require('config')

require('mini.icons').setup()
require('lualine').setup()

require'impatient'.enable_profile()

vim.cmd('so ~/.vimrc')
