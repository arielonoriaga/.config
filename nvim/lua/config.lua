vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require('impatient').enable_profile()

require("nvim-web-devicons").setup({})

require('lualine').setup()

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * 0.3
        local window_h = screen_h * 0.9
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = screen_w * 0.9 - window_w_int
        local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

        return {
          border = 'rounded',
          relative = 'editor',
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * 0.3)
    end,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
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

require('avante_lib').load()
require('avante.config').setup({})
