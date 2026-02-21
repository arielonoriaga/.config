local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Core dependencies
  { 'MunifTanjim/nui.nvim' },
  { 'nvim-lua/plenary.nvim' },

  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<A-f>",
          accept_word = "<C-j>",
          clear_suggestion = "<C-]>",
        },
        ignore_filetypes = {
          cpp = true,
        },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
      })
    end,
  },

  -- Claude Code integration (requires Claude Code CLI)
  -- {
  --   "coder/claudecode.nvim",
  --   dependencies = { "folke/snacks.nvim" },
  --   config = true,
  --   keys = {
  --     { "<leader>a", nil, desc = "AI/Claude Code" },
  --     { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
  --     { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
  --     { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
  --     { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  --     { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
  --     { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  --     {
  --       "<leader>as",
  --       "<cmd>ClaudeCodeTreeAdd<cr>",
  --       desc = "Add file",
  --       ft = { "NvimTree", "neo-tree", "oil" },
  --     },
  --     -- Diff management
  --     { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
  --     { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  --   },
  -- },

  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.4,
          position = "vertical",
          hide_numbers = true,
          enter_insert = true,
          hide_signcolumn = true,
        },
        command = "/home/ariel/.claude/local/claude"
      })
    end
  },

  -- UI and utilities
  {
    'glepnir/lspsaga.nvim',
    config = function ()
      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = true
        },
        lightbulb = {
          enable = true
        },
        diagnostic = {
          show_code_action = true,
          show_source = true,
          virtual_text = true,
        },
        hover = {
          enable = false,
        },
        ui = {
          border = "rounded"
        }
      })
    end,
    event = 'LspAttach'
  },
  { 'kdheepak/lazygit.nvim', cmd = 'LazyGit' },
  { 'machakann/vim-sandwich', event = 'BufRead' },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    config = function ()
      local spectre = require('spectre')
      vim.keymap.set('n', '<leader>S', function ()
        spectre.open()
      end, { desc = "Open Spectre" })
    end
  },

  -- Treesitter and related
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        sync_install = false,
        ensure_installed = {
          "lua", "javascript", "typescript", "html", "css", "json", "bash",
          "markdown", "markdown_inline", "vue", "tsx",
        },
        modules = {},
        ignore_install = {},
        auto_install = false,  -- Disabled for performance
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, buf)
            local max = 50 * 1024
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > max
          end,
        },
        indent = { enable = true },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = "BufReadPost",
    config = function ()
      require('treesitter-context').setup({})
    end
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
  },

  -- Telescope and extensions
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-file-browser.nvim'
    },
    build = {
      ['nvim-telescope/telescope-fzf-native.nvim'] = 'make'
    },
    cmd = 'Telescope',
    keys = {
      { ';', function() require('telescope.builtin').git_files() end, desc = 'Git files' },
      { '<C-f>', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
      { '<leader>f', function() require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') }) end, desc = 'Search word under cursor' },
      { 'gr', function() require('telescope.builtin').lsp_references() end, desc = 'LSP references' },
    },
    config = function()
      local telescope = require('telescope')

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          },
          file_ignore_patterns = { "node_modules", ".git/", "dist", "build" },
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top"
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

    end
  },

  -- File explorer and icons
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { '<C-u>', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file tree' },
      { '<C-g>', '<cmd>NvimTreeFindFile<CR>', desc = 'Find file in tree' },
    },
    config = function()
      require('nvim-tree').setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          side = 'right',
          width = function()
            return math.floor(vim.opt.columns:get() * 0.2)
          end,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Keymaps moved to lazy keys configuration
    end
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- LSP and Mason
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
  },
  { 'williamboman/mason.nvim', cmd = 'Mason' },
  { 'williamboman/mason-lspconfig.nvim', event = 'BufReadPre', dependencies = { 'williamboman/mason.nvim' } },

  -- UI enhancements
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },
  { 'voldikss/vim-floaterm', cmd = 'FloatermToggle' },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
        numhl = true,
      }
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
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
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },

  -- Statusline and bufferline
  {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    config = function()
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
          lualine_b = { 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = {},
          lualine_y = { 'progress' },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- Completion and snippets
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = 'rafamadriz/friendly-snippets',
    version = '1.*',
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      sources = {
        default = { 'path', 'lsp', 'snippets', 'buffer' },
        providers = {
          buffer = {
            opts = {
              blocked_filetypes = { 'NvimTree' },
            },
          },
          lsp = {
            opts = {
              blocked_filetypes = { 'NvimTree' },
            },
          },
        },
      },
      completion = {
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
              { "source_name", gap = 1 }
            },
            components = {
              label_description = {
                width = { max = 30 },
                text = function(ctx)
                  local detail = ctx.item.detail
                  if detail and detail ~= "" then
                    return detail
                  end
                  return ctx.item.labelDetails and ctx.item.labelDetails.description or ""
                end,
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
    },
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    event = 'BufRead',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Notifications and UI messages
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    event = 'VeryLazy',
  },

  -- Color schemes
  { 'zaldih/themery.nvim', lazy = true, cmd = 'Themery' },
  { 'ayu-theme/ayu-vim', lazy = true },
  { 'sainnhe/gruvbox-material', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { "akinsho/horizon.nvim", version = "*", lazy = true },
  { "sainnhe/sonokai", lazy = true },
  {
      "scottmckendry/cyberdream.nvim",
      lazy = false,
      priority = 1000,
  },
  {
    'egerhether/heatherfield.nvim',
    lazy = true,
    config = function()
      require('heatherfield').setup()
    end,
  },
  {
    'neanias/everforest-nvim',
    lazy = true,
    config = function()
      require('everforest').setup()
    end,
  },
})
