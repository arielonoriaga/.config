-- Enable faster lua module loading
vim.loader.enable()

vim.g.mapleader = ','

-- Load core settings first for better performance
require('sets')
require('plugins')
require('plugin_config')
require('config')
require('maps')

-- Load VimScript configs last
vim.cmd('so ~/.config/nvim/maps.vim')
if vim.fn.filereadable(vim.fn.expand('~/.vimrc')) == 1 then
  vim.cmd('so ~/.vimrc')
end

require('telescope').setup{}
require('telescope').load_extension('fzf')

-- vim.lsp.set_log_level("debug")
vim.cmd("highlight ColorColumn guibg=#533c5b")

