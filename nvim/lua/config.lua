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

require("themery").setup({
  themes = {{
      name = "Ayu",
      colorscheme = "ayu",
    },
    {
      name = "Oceanic Material",
      colorscheme = "oceanic_material",
    },
    {
      name = "Iceberg",
      colorscheme = "iceberg",
    },
    {
      name = "Tokyo Night",
      colorscheme = "tokyonight",
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
      name = "Vim One",
      colorscheme = "one",
    },
    {
      name = "Aurora",
      colorscheme = "aurora",
    },
    {
      name = "Sonokai",
      colorscheme = "sonokai",
    },
    {
      name = "Srcery",
      colorscheme = "srcery",
    },
    {
      name = "Paper Color",
      colorscheme = "PaperColor",
    },
    {
      name = "Wombat",
      colorscheme = "wombat",
    },
    {
      name = "Yorumicolors",
      colorscheme = "yorumi",
    },
    {
      name = "Gruvbox Material",
      colorscheme = "gruvbox-material",
    },
    {
      name = "Nordic",
      colorscheme = "nordic",
    },
    {
      name = "Yurumi",
      colorscheme = "yurumi",
    },
  },
})

require("mason").setup()

require('mason-lspconfig').setup({
    ensure_installed = { 'eslint' }
})

local lspconfig = require('lspconfig')

lspconfig.eslint.setup({
    settings = {
        format = { enable = true }, -- Enable formatting
        packageManager = 'npm', -- or yarn, depending on your package manager
    },
    on_attach = function(client, bufnr)
        -- Enable auto-fix on save
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "EslintFixAll", -- Trigger ESLint auto-fix
            })
        end
    end,
})
