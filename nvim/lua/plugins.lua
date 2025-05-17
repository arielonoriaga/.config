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
  { 'glepnir/lspsaga.nvim', lazy = true },
  { 'kdheepak/lazygit.nvim', cmd = 'LazyGit' },
  { 'leafoftree/vim-matchtag', event = 'BufRead' },
  { 'machakann/vim-sandwich', event = 'BufRead' },
  { 'nvim-pack/nvim-spectre', cmd = 'Spectre' },

  -- Treesitter and related
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        sync_install = false,
        ensure_installed = {
          "lua", "javascript", "typescript", "vue", "html", "css", "json", "bash",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, buf)
            local max = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > max
          end,
        },
        indent = { enable = true },
      })
    end
  },
  { 'nvim-treesitter/nvim-treesitter-context', event = 'BufRead' },

  -- Telescope and extensions
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    config = function()
      vim.keymap.set('n', "'", '<Cmd>Telescope oldfiles<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<C-f>', '<Cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', ';', '<Cmd>Telescope git_files<CR>', { noremap = true, silent = true })

      vim.keymap.set('n', 'gd', function()
        require('telescope.builtin').lsp_definitions()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', 'gr', function()
        require('telescope.builtin').lsp_references()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', 'gi', function()
        require('telescope.builtin').lsp_implementations()
      end, { noremap = true, silent = true })

      vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').live_grep({
        default_text = vim.fn.expand('<cword>'),
      }) end, { noremap = true, silent = true })
    end
  },
  { 'nvim-telescope/telescope-file-browser.nvim', cmd = 'Telescope' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cmd = 'Telescope' },

  -- File explorer and icons
  {
    'nvim-tree/nvim-tree.lua',
    lazy = false,
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
  { 'neovim/nvim-lspconfig', event = 'BufReadPre' },
  { 'williamboman/mason.nvim', cmd = 'Mason' },
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

  -- Markdown rendering
  {
    'MeanderingProgrammer/render-markdown.nvim',
    after = 'nvim-treesitter',
    lazy = true,
    ft = { 'markdown' },
    config = function()
      require('render-markdown').setup({})
    end,
  },

  -- UI enhancements
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },
  { 'voldikss/vim-floaterm', cmd = 'FloatermToggle' },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'BufRead',
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
  { 'romgrk/barbar.nvim', event = 'BufRead' },
  { 'nvim-lualine/lualine.nvim', event = 'BufRead' },

  -- Completion and snippets
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    event = 'InsertEnter',
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
  {
    'neanias/everforest-nvim',
    lazy = true,
    config = function()
      require('everforest').setup()
    end,
  },
})
