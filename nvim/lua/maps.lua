local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
  map('n', shortcut, command)
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

nmap('<leader>lg', '<cmd>LazyGit<CR>')

nmap('<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>')

nmap('<C-q>', ':q<CR>')
nmap('<C-s>', ':w<CR>')

nmap('dd', '"_dd')

nmap('fn', ":let @+=expand('%:t:r')<CR>")

vmap('cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>")

nmap('<leader>crp', ":let @+=expand('%')<CR>")
nmap('<leader>crpt', ":let @+=expand('%:r:r')<CR>")

nmap('<leader>reload', ':source ~/.vimrc<CR>')
nmap('<leader>rs', ':noh<CR>')

nmap('<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>')

vim.api.nvim_set_keymap(
    'n',
    '<leader>o',
    ':!thunar %:p:h<CR><CR>',
    { noremap = true, silent = true }
)

vim.keymap.set('n', "<F10>", ":EslintFixAll<CR>", { desc = "Run eslint fix", noremap = true, silent = true })

vim.keymap.set("v", "<F8>", function()
  local ext = vim.fn.expand("%:e")
  local tmpfile = "/tmp/nvim_selection." .. ext
  local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
  local output = "~/Screenshots/code_" .. timestamp .. ".png"

  vim.cmd('silent! normal! "vy')
  local selection = vim.fn.getreg('v')
  local f = io.open(tmpfile, "w")
  if f then
    f:write(selection)
    f:close()
  else
    print("❌ Could not write to temp file.")
    return
  end

  vim.fn.jobstart({
    "silicon",
    tmpfile,
    "-o", output
  }, {
    on_exit = function()
      vim.fn.jobstart({ "xclip", "-selection", "clipboard", "-t", "image/png", "-i", output })
      print("✅ Screenshot saved and copied to clipboard: " .. output)
    end,
    stdout_buffered = true,
    stderr_buffered = true
  })
end, { desc = "Pretty screenshot with silicon" })

vim.keymap.set('v', '<F9>', ':sort<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<F4>', ':Themery<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>tt", function()
  require("plugins.transparency").toggle()
end, { desc = "Toggle UI Transparency" })

vim.keymap.set('n', '<F5>', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<F5>', ':Lspsaga code_action<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>df', function ()
  vim.cmd('Lspsaga finder')
end, { noremap = true, silent = true, desc = 'Display Lspsaga finder' })

vim.keymap.set('n', '<leader>dic', function ()
  vim.cmd('Lspsaga incoming_calls')
end, { noremap = true, silent = true, desc = 'Display incoming Callhierarchy' })


vim.keymap.set('n', 'K', function ()
  vim.lsp.buf.hover()
end, { noremap = true, silent = true, desc = 'Display hover doc' })

vim.keymap.set('n', '<leader>doc', function ()
  vim.cmd('Lspsaga outgoing_calls')
end, { noremap = true, silent = true, desc = 'Display outgoing Callhierarchy' })

-- CodeCompanion mappings removed - plugin requires paid API
