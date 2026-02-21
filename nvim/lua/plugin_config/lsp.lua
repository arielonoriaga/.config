local lspconfig = require("lspconfig")

lspconfig.oxlint = {
  default_config = {
    cmd = { "oxlint", "lsp" },
    filetypes = { "vue" },
    root_dir = lspconfig.util.root_pattern("package.json", ".git"),
    single_file_support = true,
  },
}

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
    'vue', 'svelte', 'astro'
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

vim.lsp.enable('ts_ls', false)

-- Vue + TypeScript setup
local vue_language_server_path = '/home/ariel/.local/share/pnpm/global/5/node_modules/@vue/language-server'

lspconfig.vtsls.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue_language_server_path,
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
    typescript = {
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'vue' },
})

-- vue_ls uses the native vim.lsp API (lspconfig has it as "vue_ls" in lsp/ not configs/)
-- The native lsp/vue_ls.lua already provides the tsserver/request handler with retry logic
vim.lsp.config('vue_ls', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  filetypes = { 'vue' },
})
vim.lsp.enable('vue_ls')
