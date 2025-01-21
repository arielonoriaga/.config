local themery = require('themery')

themery.setup({
  livePreview = true,
  themes = {
    {
      name = "Ayu",
      colorscheme = "ayu",
    },
    {
      name = "Gruvbox Material",
      colorscheme = "gruvbox-material",
    },
    {
      name = "Dark - Catppuccino - Default",
      colorscheme = "catppuccin",
    },
    {
      name = "Dark - Catppuccino - Frappe",
      colorscheme = "catppuccin-frappe",
    },
    {
      name = "Light - Catppuccino - Latte",
      colorscheme = "catppuccin-latte",
    },
    {
      name = "Dark - Catppuccino - Macchiato",
      colorscheme = "catppuccin-macchiato",
    },
    {
      name = "Dark - Catppuccino - Mocha",
      colorscheme = "catppuccin-mocha",
    },
    {
      name = 'Dark - Everforest',
      colorscheme = 'everforest',
    },
    {
      name = 'Light - Everforest',
      colorscheme = 'everforest',
      before = [[
        vim.opt.background = "light"
      ]],
    }
  },
})
