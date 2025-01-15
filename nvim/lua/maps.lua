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

--sset leader
vim.g.mapleader = ','

-- Spectre mappings
nmap('<leader>S', '<cmd>lua require("spectre").open()<CR>', { desc = "Open Spectre" })
nmap('<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search current word" })
vmap('<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search selected word" })
nmap('<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = "Search in current file" })

-- Bufferline mappings
nmap('<F2>', '<cmd>BufferNext<CR>')
nmap('<F3>', '<cmd>BufferPrevious<CR>')

-- LazyGit
nmap('<leader>lg', '<cmd>LazyGit<CR>')

-- LazyDocker
nmap('<leader>ld', '<cmd>FloatermNew lazydocker<CR>')

-- Buffer management and navigation
nmap('<C-d>', ':bd!<CR>')  -- Close buffer
nmap('<C-q>', ':q<CR>')     -- Quit
nmap('<C-s>', ':w<CR>')     -- Save

-- delete withuot copying to clipboard
nmap('dd', '"_dd')

-- NERDTree and file navigation
nmap('<C-u>', '<cmd>NvimTreeToggle<CR>')
nmap('<C-g>', '<cmd>NvimTreeFindFile<CR>')

-- Startify
nmap('<C-n>', ':Startify<CR>')

-- telescope file navigation
vim.keymap.set('n', "'", "<Cmd>Telescope oldfiles<CR>", { noremap = true, silent = true })
vim.keymap.set('n', "<C-f>", "<Cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set('n', ";", "<Cmd>Telescope git_files<CR>", { noremap = true, silent = true })

vim.keymap.set('n', "<leader>f", function() require('telescope.builtin').live_grep({
  default_text = vim.fn.expand("<cword>"),
}) end, { noremap = true, silent = true })

-- Searching and aligning
nmap('sw', '*')
nmap('<leader>w', ':Grepper -tool ag -cword -noprompt<CR>')

-- Copy filename without extension
nmap('fn', ":let @+=expand('%:t:r')<CR>")

-- console log from selection
vmap('cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>")

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

vim.keymap.set('n', 'gd', function()
  require('telescope.builtin').lsp_definitions()
end, { noremap = true, silent = true })

vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end, { noremap = true, silent = true })

vim.keymap.set('n', 'gi', function()
  require('telescope.builtin').lsp_implementations()
end, { noremap = true, silent = true })

local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
end

vim.api.nvim_set_keymap('n', '<leader>fa', ':Lspsaga code_action<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap(
    'n',
    '<leader>o',
    ':!thunar %:p:h<CR><CR>',
    { noremap = true, silent = true }
)

require("mason-lspconfig").setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({
      on_attach = on_attach,
    })
  end,
})
