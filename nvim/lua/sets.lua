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
  updatetime = 300,
  backup     = false,
  swapfile   = false,
  undofile   = true,
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

local data_dir = vim.fn.stdpath("data")
opt.undodir = data_dir .. "/undo"
vim.o.viminfo = "'100," .. "n" .. data_dir .. "/viminfo"

vim.o.lazyredraw = true
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 10

opt.shortmess:append({ I = true, s = true })  -- skip the intro and search count

vim.lsp.enable('tailwindcss')
