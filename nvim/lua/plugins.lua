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

  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose", "ClaudeCodeVersion" },
    keys = { { "<C-,>", "<cmd>ClaudeCode<CR>", desc = "Claude Code" } },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.4,
          position = "vertical",
          hide_numbers = true,
          enter_insert = true,
          hide_signcolumn = true,
        },
        command = "claude"
      })
    end
  },


  {
    "aug6th/cursoragent.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "CursorAgent",
      "CursorAgentAsk",
      "CursorAgentPlan",
      "CursorAgentResume",
      "CursorAgentBuffer",
      "CursorAgentSelection",
    },
    keys = {
      { "<leader>cu", "<cmd>CursorAgent<CR>", desc = "Cursor Agent" },
      { "<leader>cua", "<cmd>CursorAgentAsk<CR>", desc = "Cursor Agent Ask" },
      { "<leader>cup", "<cmd>CursorAgentPlan<CR>", desc = "Cursor Agent Plan" },
      { "<leader>cur", "<cmd>CursorAgentResume<CR>", desc = "Cursor Agent Resume" },
      { "<leader>cub", "<cmd>CursorAgentBuffer<CR>", desc = "Cursor Agent Buffer" },
      { "<leader>cus", "<cmd>CursorAgentSelection<CR>", mode = "v", desc = "Cursor Agent Selection" },
    },
    config = function()
      require("cursoragent").setup({})
    end,
  },
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
  { 'kdheepak/lazygit.nvim', cmd = 'LazyGit', keys = { { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'LazyGit' } } },
  { 'machakann/vim-sandwich', event = 'BufRead' },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    keys = { { '<leader>S', function() require('spectre').open() end, desc = 'Open Spectre' } },
  },

  -- Treesitter and related
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      require('compat.treesitter_all_false').install()
    end,
    config = function()
      require('nvim-treesitter.configs').setup({
        sync_install = false,
        ensure_installed = {
          "lua", "javascript", "typescript", "html", "css", "json", "bash",
          "markdown", "markdown_inline", "tsx",
        },
        modules = {},
        ignore_install = {},
        auto_install = false,
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
    opts = { enable_autocmd = false },
    init = function()
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        if option ~= 'commentstring' then
          return get_option(filetype, option)
        end
        return require('ts_context_commentstring.internal').calculate_commentstring() or get_option(filetype, option)
      end
    end,
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
      require('plugin_config.telescope')
    end,
  },

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
    end
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      require('plugin_config.lsp')
    end,
  },
  { 'williamboman/mason.nvim', cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall', 'MasonLog' }, opts = {} },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = true,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = { 'lua_ls', 'vtsls', 'eslint', 'tailwindcss' },
      automatic_enable = false,
    },
  },

  { 'stevearc/dressing.nvim', event = 'VeryLazy' },
  {
    'voldikss/vim-floaterm',
    cmd = { 'FloatermToggle', 'FloatermNew' },
    keys = {
      { '<F12>', '<cmd>FloatermToggle --name=cmd<CR>', desc = 'Toggle terminal' },
      { '<F12>', '<C-\\><C-n><cmd>FloatermToggle --name=cmd<CR>', mode = 't', desc = 'Toggle terminal' },
      { '<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>', desc = 'LazyDocker' },
    },
    init = function()
      vim.g.floaterm_height = 0.9
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_autoclose = 2
    end,
  },
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

  {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
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

  {
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
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

  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    event = 'VeryLazy',
    config = function()
      require('plugin_config.noice')
    end,
  },

  {
    'zaldih/themery.nvim',
    cmd = 'Themery',
    keys = { { '<F4>', '<cmd>Themery<CR>', desc = 'Pick colorscheme' } },
    config = function()
      require('plugin_config.themery')
    end,
  },
  { 'ayu-theme/ayu-vim', lazy = true },
  { 'sainnhe/gruvbox-material', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { "akinsho/horizon.nvim", version = "*", lazy = true },
  { "sainnhe/sonokai", lazy = true },
  { "scottmckendry/cyberdream.nvim", lazy = true },
  {
    'egerhether/heatherfield.nvim',
    lazy = true,
    opts = {},
  },
  {
    'neanias/everforest-nvim',
    main = 'everforest',
    lazy = true,
    opts = {},
  },
}, {
  install = { colorscheme = { 'cyberdream' } },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'matchit', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin', 'rplugin' },
    },
  },
})
