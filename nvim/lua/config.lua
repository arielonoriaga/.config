vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require('impatient').enable_profile()

require("nvim-web-devicons").setup({
  default = true,
})

require('lualine').setup()

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
    side = "right",
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

require("lspsaga").setup({
  lightbulb = {
    enable = true,
    sign = true,
  },
})

require('nvim-treesitter.configs').setup({
  ensure_installed = { "vim", "lua", "vimdoc", "typescript" },
  highlight = {
    enable = true,
  },
})

require("themery").setup({
  themes = {{
      name = "Ayu",
      colorscheme = "ayu",
    },
    {
      name = "One Dark",
      colorscheme = "onedark",
    },
    {
      name = "Vimterial Dark",
      colorscheme = "vimterial_dark",
    },
    {
      name = "Gruvbox",
      colorscheme = "gruvbox",
    },
    {
      name = "Everforest",
      colorscheme = "everforest",
    },
    {
      name = "Monokai Tasty",
      colorscheme = "vim-monokai-tasty",
    },
    {
      name = "Gruvbox Material",
      colorscheme = "gruvbox-material",
    },
  },
})

require("mason").setup()

require('mason-lspconfig').setup({
  ensure_installed = { 'ts_ls', 'html', 'cssls', 'lua_ls' },
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})

lspconfig.ts_ls.setup({
  settings = {
    format = { enable = true },
  },
  capabilities = capabilities,
})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint.with({
      command = "eslint_d",  -- This uses eslint_d for faster linting
      args = { "--fix-dry-run", "--stdin", "--stdin-filename", "$FILENAME" }
    }),
    null_ls.builtins.code_actions.eslint,
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    if client.server_capabilities.documentFormattingProvider then
      vim.cmd([[
        augroup LspAutoFormat
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
        augroup END
      ]])
    end
  end,
})

-- lspconfig.lua_ls.setup {}

-- require('smear_cursor').enabled = true
