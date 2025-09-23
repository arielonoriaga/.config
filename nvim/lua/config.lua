vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true

local g = vim.g

g.loaded_node_provider = 0
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

require("nvim-web-devicons").setup({})

require('lualine').setup({
  options = {
    theme = 'nord',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {{
      'mode',
      fmt = function(str) return str:sub(1,1) end
    }},
    lualine_b = {'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {},
    lualine_y = {'progress'},
    lualine_z = {}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
})

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
