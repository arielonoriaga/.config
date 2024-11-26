local h_pct = 0.90
local w_pct = 0.80

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
        preview_width = 0.5,
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
        preview_height = 0.5,
      },
    },
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<Esc>"] = require('telescope.actions').close,
      },
      n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<Esc>"] = require('telescope.actions').close,
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

