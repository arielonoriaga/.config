vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require("nvim-web-devicons").setup({})

require('lualine').setup()

require('which-key').setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
  },
  win = {
    title = false,
  },
  preset = 'helix',
})
