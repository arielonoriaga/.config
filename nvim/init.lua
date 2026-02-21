-- Enable faster lua module loading
vim.loader.enable()

vim.g.mapleader = ','

-- Load core settings first for better performance
require('sets')
require('plugins')
require('plugin_config')
require('maps')


-- vim.lsp.set_log_level("debug")
vim.cmd("highlight ColorColumn guibg=#533c5b")
