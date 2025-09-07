local themery = require('themery')

local function create_theme(name, colorscheme, backgroundmode)
  return {
    name = string.format("%s - %s", backgroundmode:gsub("^%l", string.upper), name),
    colorscheme = colorscheme,
    before = string.format([[vim.opt.background = "%s"]], backgroundmode),
  }
end

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
    create_theme("Everforest", "everforest", "dark"),
    create_theme("Everforest", "everforest", "light"),
    create_theme("Horizon", "horizon", "dark"),
    create_theme("Heatherfield", "heatherfield", "dark"),
    create_theme("Sonokai", "sonokai", "dark"),
    {
      name = "Spring Night",
      colorscheme = "spring-night",
    },
    create_theme("Cyberdream", "cyberdream", "dark"),
    create_theme("Cyberdream", "cyberdream", "light"),
  },
})
