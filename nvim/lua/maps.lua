local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map('n', '<C-q>', '<cmd>q<CR>', 'Quit')
map('n', '<C-s>', '<cmd>w<CR>', 'Save')
map('n', 'dd', '"_dd', 'Delete line (no yank)')
map('n', '<leader>rs', '<cmd>nohlsearch<CR>', 'Clear search highlight')
map('n', '<leader>dts', [[<cmd>let _s=@/ | %s/\s\+$//e | let @/=_s | nohlsearch<CR>]], 'Delete trailing spaces')
map('v', '<F9>', ':sort<CR>', 'Sort selection')

map('n', 'fn', function() vim.fn.setreg('+', vim.fn.expand('%:t:r')) end, 'Copy filename')
map('n', '<leader>crp', function() vim.fn.setreg('+', vim.fn.expand('%')) end, 'Copy relative path')
map('n', '<leader>crpt', function() vim.fn.setreg('+', vim.fn.expand('%:r:r')) end, 'Copy path (no ext)')
map('n', '<leader>o', function() vim.fn.jobstart({ 'thunar', vim.fn.expand('%:p:h') }, { detach = true }) end, 'Open file manager')
map('v', 'cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>", 'Console.log selection')

map('n', '<leader>tt', function() require('transparency').toggle() end, 'Toggle transparency')

map('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', 'Go to definition')
map('n', 'gi', function() vim.lsp.buf.implementation() end, 'Go to implementation')
map('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', 'Peek definition')
map('n', 'gt', '<cmd>Lspsaga goto_type_definition<CR>', 'Go to type definition')
map('n', 'K', function() vim.lsp.buf.hover() end, 'Hover documentation')
map({ 'n', 'v' }, '<F5>', '<cmd>Lspsaga code_action<CR>', 'Code action')
map('n', '<F10>', '<cmd>LspEslintFixAll<CR>', 'ESLint fix all')
map('n', '<leader>df', '<cmd>Lspsaga finder<CR>', 'Lspsaga finder')
map('n', '<leader>dic', '<cmd>Lspsaga incoming_calls<CR>', 'Incoming calls')
map('n', '<leader>doc', '<cmd>Lspsaga outgoing_calls<CR>', 'Outgoing calls')

local function screenshot_selection()
  vim.cmd('silent! normal! "vy')
  local source = vim.fn.tempname() .. '.' .. vim.fn.expand('%:e')
  local output = vim.fn.expand('~/Screenshots/code_' .. os.date('%Y-%m-%d_%H-%M-%S') .. '.png')
  vim.fn.writefile(vim.split(vim.fn.getreg('v'), '\n'), source)
  vim.fn.jobstart({ 'silicon', source, '-o', output }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify('silicon failed (' .. code .. ')', vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart({ 'sh', '-c', 'wl-copy --type image/png < ' .. vim.fn.shellescape(output) })
      vim.notify('Screenshot saved and copied: ' .. output)
    end,
  })
end

map('v', '<F8>', screenshot_selection, 'Pretty screenshot with silicon')
