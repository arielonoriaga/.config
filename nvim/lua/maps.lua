-- Helper functions for mapping
local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
  map('n', shortcut, command)
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

-- Leader key setup (ensure this is set early in your config)
vim.g.mapleader = ','  -- Set leader key to space

-- Spectre mappings
nmap('<leader>S', '<cmd>lua require("spectre").open()<CR>', { desc = "Open Spectre" })
nmap('<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search current word" })
vmap('<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search selected word" })
nmap('<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = "Search in current file" })

-- LazyGit
nmap('<leader>lg', '<cmd>LazyGit<CR>')

-- LazyDocker
nmap('<leader>ld', '<cmd>FloatermNew lazydocker<CR>')

-- use coc for code navigation
nmap('gd', '<Plug>(coc-definition)')
nmap('gy', '<Plug>(coc-type-definition)')
nmap('gi', '<Plug>(coc-implementation)')
nmap('gr', '<Plug>(coc-references)')

-- Buffer management and navigation
nmap('<C-d>', ':bd!<CR>')  -- Close buffer
nmap('<C-i>', ':bn<CR>')    -- Next buffer
nmap('<C-q>', ':q<CR>')     -- Quit
nmap('<C-s>', ':w<CR>')     -- Save

-- delete withuot copying to clipboard
nmap('dd', '"_dd')

-- NERDTree and file navigation
nmap('<C-u>', '<cmd>NvimTreeToggle<CR>')
nmap('<C-g>', '<cmd>NvimTreeFindFile<CR>')

-- Startify
nmap('<C-n>', ':Startify<CR>')

-- FZF file navigation
nmap("'", ':History<CR>')
nmap(';', ':GFiles<CR>')

-- Searching and aligning
nmap('<C-f>', ':FindByContent<CR>')
nmap('gs', ':CocSearch<CR>')
nmap('sw', '*')
nmap('<leader>w', ':Grepper -tool ag -cword -noprompt<CR>')

-- Moving lines
nmap('J', ':m .+1<CR>')
nmap('K', ':m .-2<CR>')

-- Visual mode mappings
local opts = { noremap = true, silent = true }
vmap('<C-l>', ':sort<CR>', opts)
vmap('<C-e>', ':lua require("coc").action("runCommand", "tsserver.executeAutofix")<CR>', opts)
vmap('<C-h>', ':lua require("coc").action("runCommand", "editor.action.organizeImport")<CR>', opts)

-- Normal mode mappings
nmap('<C-e>', ':lua require("coc").action("runCommand", "tsserver.executeAutofix")<CR>', opts)
nmap('<C-h>', ':lua require("coc").action("runCommand", "editor.action.organizeImport")<CR>', opts)

-- Insert mode mapping for Copilot
vim.api.nvim_set_keymap('i', '<C-e>', 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })

-- Insert mode mapping for Coc
vim.api.nvim_set_keymap('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]], {expr = true, noremap = true})

vim.api.nvim_set_keymap(
    'n', 
    '<leader>ef', 
    '<cmd>EslintFixAll<CR>', 
    { noremap = true, silent = true }
)

-- Resizing windows
nmap('U', '<C-w>>')
nmap('Y', '<C-w><')

-- Copy filename without extension
nmap('fn', ":let @+=expand('%:t:r')<CR>")

-- Code refactoring and actions
nmap('M', '<Plug>NERDCommenterToggle')
vmap('M', '<Plug>NERDCommenterToggle')

-- Leader mappings
nmap('<leader>r', ':NERDTreeFocus<CR>R<C-w><C-p>')  -- Reload NERDTree
nmap('<leader>ro', ':so ~/.config/nvim/init.lua<CR>')  -- Reload init.lua

-- Copy <leader> file path and name
nmap('<leader>crp', ":let @+=expand('%')<CR>")
nmap('<leader>crpt', ":let @+=expand('%:r:r')<CR>")

-- Miscellaneous
nmap('<leader>reload', ':source ~/.vimrc<CR>')  -- Reload Vim config
nmap('<leader>rs', ':noh<CR>')                  -- Clear search highlight

-- delete trailing whitespace
nmap('<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>')
