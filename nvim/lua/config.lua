vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

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
    dotfiles = true,
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
    }
  },
})
