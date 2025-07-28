local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- LSP configuration using blink.cmp capabilities
mason.setup()

mason_lspconfig.setup({
  ensure_installed = { "html", "cssls" },
  automatic_enable = true,
  automatic_installation = true,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
