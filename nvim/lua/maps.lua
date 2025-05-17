local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
  map('n', shortcut, command)
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

-- nmap('<F2>', '<cmd>BufferNext<CR>')
-- nmap('<F3>', '<cmd>BufferPrevious<CR>')

nmap('<leader>lg', '<cmd>LazyGit<CR>')

nmap('<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>')

nmap('<C-d>', ':bd!<CR>')
nmap('<C-q>', ':q<CR>')
nmap('<C-s>', ':w<CR>')

nmap('dd', '"_dd')

nmap('fn', ":let @+=expand('%:t:r')<CR>")

vmap('cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>")

nmap('<leader>ro', ':so ~/.config/nvim/init.lua<CR>')

nmap('<leader>crp', ":let @+=expand('%')<CR>")
nmap('<leader>crpt', ":let @+=expand('%:r:r')<CR>")

nmap('<leader>reload', ':source ~/.vimrc<CR>')
nmap('<leader>rs', ':noh<CR>')

nmap('<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>')

vim.api.nvim_set_keymap('n', '<leader>fa', ':Lspsaga code_action<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap(
    'n',
    '<leader>o',
    ':!thunar %:p:h<CR><CR>',
    { noremap = true, silent = true }
)
