local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  completion = {
    completeopt = 'menu,menuone',
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'render-markdown' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'path' },
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = '[LSP]',
        luasnip = '[LuaSnip]',
        buffer = '[Buffer]',
        nvim_lua = '[Lua]',
        path = '[Path]',
      })[entry.source.name]
      return vim_item
    end,
  },
})

require("lspsaga").setup({
  lightbulb = {
    enable = true,
    sign = true,
  },
})

require('nvim-treesitter.configs').setup({
  sync_install = false,
  modules = {},
  ignore_install = {},
  ensure_installed = { "javascript", "typescript", "lua", "vimdoc" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ident = {
    enable = false,
  },
})

vim.opt.lazyredraw = true

require("mason").setup()

require('mason-lspconfig').setup({
  ensure_installed = { 'ts_ls', 'html', 'cssls', 'lua_ls', 'rust_analyzer' },
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})

lspconfig.ts_ls.setup({
  settings = {
    format = { enable = true },
    completions = { completeFunctionCalls = true },
  },
  capabilities = capabilities,
})

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy", -- Enable Clippy for linting
      },
    },
  },
})

-- require("copilot").setup({
--   panel = {
--     auto_refresh = false,
--     keymap = {
--       accept = "<CR>",
--       jump_prev = "[[",
--       jump_next = "]]",
--       refresh = "gr",
--       open = "<M-CR>",
--     },
--   },
--   suggestion = {
--     auto_trigger = true,
--     keymap = {
--       accept = "<M-l>",
--       prev = "<M-[>",
--       next = "<M-]>",
--       dismiss = "<C-]>",
--     },
--   },
-- })

