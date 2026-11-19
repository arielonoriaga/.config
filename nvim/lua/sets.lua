local opt = vim.opt

local ui = {
  termguicolors  = true,
  laststatus     = 3,
  cursorline     = true,
  colorcolumn    = "80",
  wrap           = false,
  scrolloff      = 8,
  number         = true,
  numberwidth    = 2,
  relativenumber = true,
  signcolumn     = "yes",
}

local indent = {
  expandtab      = true,
  tabstop        = 2,
  shiftwidth     = 2,
  softtabstop    = 2,
  smartindent    = true,
  foldmethod     = "expr",
  foldexpr       = "v:lua.vim.treesitter.foldexpr()",
  foldlevelstart = 2,
  foldnestmax    = 2,
  foldcolumn     = "0",
}

local search = {
  ignorecase = true,
  smartcase  = true,
}

local files = {
  updatetime = 100,
  swapfile   = false,
  undofile   = true,
  undodir    = vim.fn.stdpath("data") .. "/undo",
  shada      = "'100,n" .. vim.fn.stdpath("data") .. "/viminfo",
  timeoutlen = 300,
  ttimeoutlen = 5,
}

for _, group in ipairs({ ui, indent, search, files }) do
  for name, value in pairs(group) do
    opt[name] = value
  end
end

opt.path:append("**")
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.wildmode = "longest:full,full"
opt.shortmess:append({ I = true, s = true })
opt.clipboard = vim.fn.has("macunix") == 1 and "unnamed" or "unnamedplus"

for _, provider in ipairs({ "node", "perl", "ruby", "python3" }) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end
