local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- LSP configuration using blink.cmp capabilities
lspconfig.lua_ls.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})

lspconfig.eslint.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.implementationProvider = false
    client.server_capabilities.renameProvider = false
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.signatureHelpProvider = false

    if client.server_capabilities.codeActionProvider then
      local group = vim.api.nvim_create_augroup('EslintAutofix', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        buffer = bufnr,
        command = 'EslintFixAll',
      })
    end
  end,
  settings = {
    codeActionOnSave = {
      enable = true,
      mode = 'all',
    },
  },
})

mason.setup()

mason_lspconfig.setup({
  ensure_installed = { "lua_ls", "html", "cssls" },
  automatic_enable = true,
  automatic_installation = true,
})

-- Configure Volar
lspconfig.volar.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  filetypes = { 'vue' },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})