local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- LSP configuration using blink.cmp capabilities
mason.setup()

-- v2 auto-enables every mason-installed server; ts_ls is uninstalled (vtsls covers TS/TSX)
mason_lspconfig.setup({})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
