local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, {noremap = true, silent = true})
end

local function nmap(shortcut, command)
  map('n', shortcut, command)
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

nmap('<c-d>', ':bd!<cr>')
nmap('<c-g>', ':NERDTreeFind<cr>')
nmap('<c-i>', ':bn<cr>')
nmap('<c-n>', ':Startify<cr>')
nmap('<c-q>', ':q<cr>')
nmap('<c-s>', ':w<cr>')
nmap('<c-u>', ':NERDTreeToggle<cr>')
nmap('<c-x>', ':bufdo bd!<cr>')

nmap("'", ':History<cr>')
nmap(';', ':GFiles<cr>')
nmap('<c-f>', ':FindByContent<cr>')
nmap('J', ':m.1<cr>')
nmap('K', ':m-2<cr>')
nmap('U', '<c-w>>')
nmap('Y', '<c-w><')
nmap('cfn', ":let @+=expand('%:t:r')<cr>")
nmap('fn', ":let @+=expand('%:t:r')<cr> ;")
nmap('gs', ':CocSearch')
nmap('sf', 'cw ;')
nmap('sw', '*')
nmap('t', '%')

vmap('<c-l', ':sort<cr>')
vmap('t', '%')
