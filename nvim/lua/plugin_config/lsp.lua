-- All servers use the vim.lsp.config/enable API (Neovim 0.11+).
-- nvim-lspconfig is still required as a plugin: it ships the lsp/*.lua server
-- definitions these calls read. We just no longer require('lspconfig').

local function caps()
  return require('blink.cmp').get_lsp_capabilities()
end

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
  capabilities = caps(),
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

vim.lsp.config('eslint', {
  capabilities = caps(),
  filetypes = {
    'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
    'svelte', 'astro'
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
vim.lsp.enable('eslint')

-- ts_ls stays off; vtsls handles TypeScript.
vim.lsp.enable('ts_ls', false)

vim.lsp.config('vtsls', {
  capabilities = caps(),
  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
})
vim.lsp.enable('vtsls')
