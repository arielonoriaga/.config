-- Floaterm settings (migrated from maps.vim)
vim.g.floaterm_height = 0.9
vim.g.floaterm_width = 0.9
vim.g.floaterm_autoclose = 2

vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<CR>', { noremap = true, silent = true, desc = 'LazyGit' })

vim.keymap.set('n', '<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>', { noremap = true, silent = true, desc = 'LazyDocker' })

vim.keymap.set('n', '<C-q>', ':q<CR>', { noremap = true, silent = true, desc = 'Quit' })
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true, desc = 'Save' })

vim.keymap.set('n', 'dd', '"_dd', { noremap = true, silent = true, desc = 'Delete line (no yank)' })

vim.keymap.set('n', 'fn', ":let @+=expand('%:t:r')<CR>", { noremap = true, silent = true, desc = 'Copy filename' })

vim.keymap.set('v', 'cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>", { noremap = true, silent = true, desc = 'Console.log selection' })

vim.keymap.set('n', '<leader>crp', ":let @+=expand('%')<CR>", { noremap = true, silent = true, desc = 'Copy relative path' })
vim.keymap.set('n', '<leader>crpt', ":let @+=expand('%:r:r')<CR>", { noremap = true, silent = true, desc = 'Copy path (no ext)' })

vim.keymap.set('n', '<leader>rs', ':noh<CR>', { noremap = true, silent = true, desc = 'Clear search highlight' })

vim.keymap.set('n', '<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>', { noremap = true, silent = true, desc = 'Delete trailing spaces' })

vim.keymap.set('n', '<leader>o', ':!thunar %:p:h<CR><CR>', { noremap = true, silent = true, desc = 'Open file manager' })

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


vim.keymap.set('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { noremap = true, silent = true, desc = 'Go to definition' })
vim.keymap.set('n', 'gi', '<cmd>Lspsaga goto_implementation<CR>', { noremap = true, silent = true, desc = 'Go to implementation' })
vim.keymap.set('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { noremap = true, silent = true, desc = 'Peek definition' })
vim.keymap.set('n', 'gt', '<cmd>Lspsaga goto_type_definition<CR>', { noremap = true, silent = true, desc = 'Go to type definition' })

vim.keymap.set('n', 'K', function ()
  vim.lsp.buf.hover()
end, { noremap = true, silent = true, desc = 'Display hover doc' })

vim.keymap.set('n', '<leader>doc', function ()
  vim.cmd('Lspsaga outgoing_calls')
end, { noremap = true, silent = true, desc = 'Display outgoing Callhierarchy' })

-- CodeCompanion mappings removed - plugin requires paid API

-- Terminal mode mappings for floatterm
vim.keymap.set('t', '<C-r>', '<C-r>', { noremap = false, silent = true, desc = 'Enable Ctrl+R in terminal' })

-- Floaterm toggle (migrated from maps.vim)
vim.keymap.set('n', '<F12>', '<cmd>FloatermToggle --name=cmd<CR>', { noremap = true, silent = true, desc = 'Toggle terminal' })
vim.keymap.set('t', '<F12>', '<C-\\><C-n><cmd>FloatermToggle --name=cmd<CR>', { noremap = true, silent = true, desc = 'Toggle terminal' })
