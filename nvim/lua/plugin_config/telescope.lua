local h_pct = 0.9
local w_pct = 0.95

local telescope = require('telescope')

telescope.load_extension('fzf')

telescope.setup({
  defaults = {
    prompt_prefix = "❯ ",
    selection_caret = "❯ ",
    layout_config = {
      flex = { flip_columns = 100 },
      horizontal = {
        mirror = false,
        prompt_position = 'top',
        width = function(_, cols, _)
          return math.floor(cols * w_pct)
        end,
        height = function(_, _, rows)
          return math.floor(rows * h_pct)
        end,
        preview_cutoff = 10,
        preview_width = 0.7,
      },
      vertical = {
        mirror = true,
        prompt_position = 'top',
        width = function(_, cols, _)
          return math.floor(cols * w_pct)
        end,
        height = function(_, _, rows)
          return math.floor(rows * h_pct)
        end,
        preview_cutoff = 10,
        preview_height = 0.7,
      },
    },
    sorting_strategy = "ascending",
    path_display = { "filename_first" },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<Esc>"] = require('telescope.actions').close,
        ["<C-h>"] = "which_key",
      },
      n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<Esc>"] = require('telescope.actions').close,
        ["<C-h>"] = "which_key",
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
})

