local lspconfig = require("lspconfig")

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})
vim.lsp.enable('rust_analyzer')

vim.lsp.config('lua_ls', {
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
vim.lsp.enable('lua_ls')

lspconfig.eslint.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  filetypes = {
    'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
  },
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

-- TypeScript/TSX/JS/JSX — vtsls defaults already cover all four filetypes
vim.lsp.config('vtsls', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
})
vim.lsp.enable('vtsls')
