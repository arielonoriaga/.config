vim.loader.enable()

vim.g.mapleader = ','

require('sets')
require('plugins')
require('transparency').setup()
require('theme').apply()
require('maps')

vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#533c5b' })
