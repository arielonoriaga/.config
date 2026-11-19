local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- LSP configuration using blink.cmp capabilities
mason.setup()

-- vtsls covers TS/TSX, so ts_ls never auto-starts even when mason has it installed
mason_lspconfig.setup({ automatic_enable = { exclude = { "ts_ls" } } })

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
