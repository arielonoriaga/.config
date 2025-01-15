-- Ensure packer.nvim is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
  end

end
ensure_packer()

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

require('packer').startup(function(use)
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'glepnir/lspsaga.nvim',
    'MunifTanjim/nui.nvim',
    'wbthomason/packer.nvim',
    'voldikss/vim-floaterm',
    'kdheepak/lazygit.nvim',
    'nvim-pack/nvim-spectre',
    'nvim-tree/nvim-web-devicons',
    'stevearc/dressing.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter-context',
    'leafoftree/vim-matchtag',
    'machakann/vim-sandwich',
    'atiladefreitas/dooing'
  }

  use {
    'MeanderingProgrammer/render-markdown.nvim',
    after = { 'nvim-treesitter' },
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('render-markdown').setup({})
    end,
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }

  use {
    'yetone/avante.nvim',
    requires = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
  }

  use {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        current_line_blame_opts = {
          delay = 500,
        },
        current_line_blame = true,
        numhl = true,
      }
    end
  }

  use {
    'folke/which-key.nvim',
    lazy = true,
    opts = {
      preset = "modern"
    },
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
        require('nvim-autopairs').setup {}
    end
  }

  use {
    'romgrk/barbar.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }

  use {
    "L3MON4D3/LuaSnip",
    run = "make install_jsregexp",
    requires = {
      "rafamadriz/friendly-snippets"
    }
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip'
    }
  }

  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use {
    'startup-nvim/startup.nvim',
    requires = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim'
    },
    config = function()
      require'startup'.setup()
    end
  }

  use {
    'folke/noice.nvim',
    requires = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify'
    }
  }

  -- colorscheme picker
  use 'zaldih/themery.nvim'

  -- Colorschemes
  use 'ayu-theme/ayu-vim'
  use 'sainnhe/gruvbox-material'
  use { "catppuccin/nvim", as = "catppuccin" }

  -- Optional: Speed up loading time
  use 'lewis6991/impatient.nvim'
end)
