vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  severity_sort = true,
  float = { border = 'rounded', source = true },
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = 'clippy' },
    },
  },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
    },
  },
})

local eslint_owns_only_lint_and_fixes = {
  'documentFormattingProvider', 'documentRangeFormattingProvider', 'definitionProvider', 'referencesProvider',
  'implementationProvider', 'renameProvider', 'hoverProvider', 'signatureHelpProvider',
}

local upstream_eslint_on_attach = vim.lsp.config.eslint.on_attach

vim.lsp.config('eslint', {
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'svelte', 'astro' },
  on_attach = function(client, bufnr)
    if upstream_eslint_on_attach then
      upstream_eslint_on_attach(client, bufnr)
    end
    for _, capability in ipairs(eslint_owns_only_lint_and_fixes) do
      client.server_capabilities[capability] = false
    end
    if client.server_capabilities.codeActionProvider then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('EslintAutofix' .. bufnr, { clear = true }),
        buffer = bufnr,
        command = 'LspEslintFixAll',
      })
    end
  end,
  settings = {
    codeActionOnSave = { enable = true, mode = 'all' },
  },
})

vim.lsp.config('vtsls', {
  settings = {
    typescript = {
      preferences = { includePackageJsonAutoImports = 'on' },
    },
  },
})

local upstream_oxlint_root_dir = vim.lsp.config.oxlint.root_dir

local function oxlint_installed_for(root)
  return vim.fn.executable(vim.fs.joinpath(root, 'node_modules/.bin/oxlint')) == 1 or vim.fn.executable('oxlint') == 1
end

vim.lsp.config('oxlint', {
  root_dir = function(bufnr, on_dir)
    upstream_oxlint_root_dir(bufnr, function(root)
      if oxlint_installed_for(root) then
        on_dir(root)
      end
    end)
  end,
})

local function has_binary(name)
  local cmd = vim.lsp.config[name].cmd
  return type(cmd) ~= 'table' or vim.fn.executable(cmd[1]) == 1
end

local function typescript_server()
  local native_typescript_7 = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason/bin/tsc')
  return vim.fn.executable(native_typescript_7) == 1 and 'tsc' or 'vtsls'
end

vim.lsp.enable(vim.tbl_filter(has_binary, {
  'rust_analyzer', 'lua_ls', 'eslint', 'oxlint', 'tailwindcss', typescript_server(),
}))
