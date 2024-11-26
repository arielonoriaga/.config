-- General settings
local opt = vim.opt  -- Shorter alias for global options

opt.background = "dark"
opt.clipboard = vim.fn.has("macunix") == 1 and "unnamed" or "unnamedplus"
opt.termguicolors = vim.fn.has("termguicolors") == 1

-- Editor appearance and behavior
opt.cmdheight = 1
opt.colorcolumn = "80"
opt.cursorline = true
opt.encoding = "UTF-8"
opt.expandtab = true
opt.path:append("**")
opt.foldcolumn = "0"
opt.foldlevelstart = 2
opt.foldmethod = "syntax"
opt.foldnestmax = 2
opt.hidden = true
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.laststatus = 3  -- Combined statusline for all windows
opt.backup = false
opt.errorbells = false
opt.wrap = false
opt.number = true
opt.numberwidth = 1
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.shortmess:append("c")
opt.showcmd = true
opt.showmatch = true
opt.showtabline = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.softtabstop = 4
opt.tabstop = 2
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.updatetime = 300
opt.viminfo = "'100,n" .. vim.fn.expand("$HOME/.vim/files/info/viminfo")

vim.api.nvim_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
