vim.opt.termguicolors = true

local g = vim.g

g.loaded_node_provider = 0
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

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
