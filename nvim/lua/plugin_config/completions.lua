local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- LSP configuration using blink.cmp capabilities
mason.setup()

mason_lspconfig.setup({
  automatic_installation = true,
  handlers = {
    -- Disable ts_ls in favor of vtsls
    function(server_name)
      if server_name == "ts_ls" or server_name == "tsserver" then
        return
      end
      require("lspconfig")[server_name].setup({})
    end,
  },
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
