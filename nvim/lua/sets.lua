local opt = vim.opt

-- Interface
local ui = {
  background     = "dark",
  termguicolors  = true,
  cmdheight      = 1,
  laststatus     = 3,
  showcmd        = true,
  cursorline     = true,
  colorcolumn    = "80",
  wrap           = false,
  scrolloff      = 8,
  number         = true,
  numberwidth    = 2,
  -- relativenumber = true,
  signcolumn     = "yes",
}

-- Tabs, Indents & Folding
local indent = {
  expandtab      = true,
  tabstop        = 2,
  shiftwidth     = 2,
  softtabstop    = 2,
  smartindent    = true,
  foldmethod     = "syntax",
  foldlevelstart = 2,
  foldnestmax    = 2,
  foldcolumn     = "0",
}

-- Search
local search = {
  hlsearch   = true,
  incsearch  = true,
  ignorecase = true,
  smartcase  = true,
}

-- Performance & Files
local perf = {
  hidden     = true,
  updatetime = 100,  -- Faster CursorHold events
  backup     = false,
  swapfile   = false,
  undofile   = true,
  -- Performance optimizations
  lazyredraw = true,  -- Don't redraw during macros
  ttyfast    = true,  -- Faster terminal connection
  -- regexpengine = 1,   -- Use old regex engine (can be slower for Telescope)
}

for _, group in ipairs({ui, indent, search, perf}) do
  if type(group) == "table" then
    for k, v in pairs(group) do
      opt[k] = v
    end
  end
end

-- Path & Providers
opt.path:append("**")
vim.g.loaded_node_provider  = 0
vim.g.loaded_perl_provider  = 0
vim.g.loaded_ruby_provider  = 0

opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.wildmenu     = true
opt.wildmode     = "longest:full,full"

vim.o.clipboard = vim.fn.has("macunix") == 1 and "unnamed" or "unnamedplus"

-- LSP completion
vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

-- Performance: Disable some built-in plugins
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logipat = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_matchit = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

local data_dir = vim.fn.stdpath("data")
opt.undodir = data_dir .. "/undo"
vim.o.viminfo = "'100," .. "n" .. data_dir .. "/viminfo"

vim.o.timeoutlen = 300  -- Faster key sequence timeout
vim.o.ttimeoutlen = 5   -- Faster escape sequence timeout

opt.shortmess:append({ I = true, s = true })  -- skip the intro and search count

vim.lsp.enable('tailwindcss')
