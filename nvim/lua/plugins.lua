local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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

  -- UI and utilities
  {
    'glepnir/lspsaga.nvim',
    lazy = true,
    config = function ()
      require('lspsaga').setup({})
    end
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
    event = { 'BufRead' },
    config = function()
      require('nvim-treesitter.configs').setup({
        sync_install = false,
        ensure_installed = {
          "vue", "lua", "javascript", "typescript", "html", "css", "json", "bash",
        },
        modules = {},
        ignore_install = {},
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, buf)
            local max = 50 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
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
    after = 'nvim-treesitter',
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
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    lazy = false,
    config = function()
      require("telescope").setup()

      local builtin = require('telescope.builtin')

      vim.keymap.set('n', ';', function()
        builtin.git_files()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', '<C-f>', function()
        builtin.live_grep()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', 'gd', function()
        builtin.lsp_definitions()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', 'gr', function()
        builtin.lsp_references()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', 'gi', function()
        builtin.lsp_implementations()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', '<leader>f', function() builtin.live_grep({
        default_text = vim.fn.expand('<cword>'),
      }) end, { noremap = true, silent = true })
    end
  },
  {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cmd = 'Telescope' },

  -- File explorer and icons
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    event = "VeryLazy",
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

      vim.keymap.set('n', '<C-u>', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<C-g>', '<cmd>NvimTreeFindFile<CR>', { noremap = true, silent = true })
    end
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- LSP and Mason
  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
  },
  { 'williamboman/mason.nvim', cmd = 'Mason', event = 'VeryLazy' },
  { 'williamboman/mason-lspconfig.nvim', event = 'BufReadPre', dependencies = { 'williamboman/mason.nvim' } },

  -- Typescript tools
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('typescript-tools').setup {
        settings = {
          tsserver_file_preferences = {
            organizeImportsCaseFirst = 'upper',
            quotePreference = 'single',
          },
          tsserver_plugins = {
            "@styled/typescript-styled-plugin",
          }
          -- tsserver_format_options = {}
        }
      }

      vim.keymap.set('n', '<leader>tf', function()
        vim.cmd('TSToolsAddMissingImports')
        vim.cmd('TSToolsOrganizeImports')
        vim.cmd('TSToolsFixAll')
        vim.cmd('TSToolsRemoveUnused')
      end, { desc = 'Run all TS tools' })
    end,
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- UI enhancements
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },
  { 'voldikss/vim-floaterm', cmd = 'FloatermToggle' },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
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
    opts = {
      presets = { operators = false },
    },
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },

  -- Statusline and bufferline
  {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    config = function ()
    	require("lualine").setup()
    end
  },

  -- Completion and snippets
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp', event = 'InsertEnter' },
      'saadparwaiz1/cmp_luasnip',
      { 'rafamadriz/friendly-snippets', lazy = true },
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
  {
      "antonyz89/electron-vue.nvim",
      dependencies = { "rktjmp/lush.nvim" }
  },
  {
    'neanias/everforest-nvim',
    lazy = true,
    config = function()
      require('everforest').setup()
    end,
  },
})
